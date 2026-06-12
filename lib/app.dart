import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/config/routes.dart';
import 'package:tramites_app/config/theme.dart';
import 'package:tramites_app/data/local/app_database.dart';
import 'package:tramites_app/data/local/file_storage_service.dart';
import 'package:tramites_app/data/local/modelo_local_manager.dart';
import 'package:tramites_app/data/repositories/archivos_repository.dart';
import 'package:tramites_app/data/repositories/outbox_repository.dart';
import 'package:tramites_app/data/repositories/solicitudes_repository.dart';
import 'package:tramites_app/data/repositories/tramites_repository.dart';
import 'package:tramites_app/data/sync/sync_manager.dart';
import 'package:tramites_app/providers/agente_tramites_provider.dart';
import 'package:tramites_app/providers/auth_provider.dart';
import 'package:tramites_app/providers/conectividad_provider.dart';
import 'package:tramites_app/providers/notification_provider.dart';
import 'package:tramites_app/providers/solicitudes_provider.dart';
import 'package:tramites_app/providers/tramites_provider.dart';
import 'package:tramites_app/services/agente_tramites_service.dart';
import 'package:tramites_app/services/api_service.dart';
import 'package:tramites_app/services/asistente_local.dart';
import 'package:tramites_app/services/asistente_local_gemma.dart';
import 'package:tramites_app/services/auth_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ApiService _apiService;
  late final AppDatabase _db;
  late final TramitesRepository _tramitesRepo;
  late final SolicitudesRepository _solicitudesRepo;
  late final OutboxRepository _outboxRepo;
  late final ArchivosRepository _archivosRepo;
  late final FileStorageService _fileStorage;
  late final ModeloLocalManager _modeloManager;
  late final AsistenteLocal _asistenteLocal;
  late final SyncManager _syncManager;
  late final AuthProvider _authProvider;
  late final NotificationProvider _notifProvider;
  late final ConectividadProvider _conectividadProvider;
  late final GoRouter _router;
  bool _notifInitialized = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _db = AppDatabase();
    _tramitesRepo = TramitesRepository(_db);
    _solicitudesRepo = SolicitudesRepository(_db);
    _outboxRepo = OutboxRepository(_db);
    _archivosRepo = ArchivosRepository(_db);
    _fileStorage = FileStorageService();
    _modeloManager = ModeloLocalManager();
    _asistenteLocal = AsistenteLocalGemma(_modeloManager);
    _syncManager = SyncManager(
      _apiService,
      _solicitudesRepo,
      _tramitesRepo,
      _outboxRepo,
      _fileStorage,
      _archivosRepo,
    );
    _authProvider = AuthProvider(AuthService(), _apiService);
    _notifProvider = NotificationProvider(_apiService);
    _conectividadProvider = ConectividadProvider();
    // Al recuperar la conexión, re-sincronizar (si hay sesión).
    _conectividadProvider.alReconectar = () {
      if (_authProvider.isLoggedIn) _syncManager.prefetchInicial();
    };
    _router = createRouter(_authProvider);

    _authProvider.addListener(_onAuthChange);
    _notifProvider.addListener(_onNotificationChange);

    _authProvider.init();
  }

  void _onAuthChange() {
    if (_authProvider.isLoggedIn &&
        !_notifInitialized &&
        _authProvider.userId != null) {
      _notifInitialized = true;
      _notifProvider.init(_authProvider.userId!);
      // Prefetch al loguear / restaurar sesión (best-effort si hay internet).
      _syncManager.prefetchInicial();
    } else if (!_authProvider.isLoggedIn && _notifInitialized) {
      _notifInitialized = false;
      _notifProvider.reset();
    }
  }

  void _onNotificationChange() {
    final route = _notifProvider.consumePendingRoute();
    if (route != null) {
      _router.go(route);
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChange);
    _notifProvider.removeListener(_onNotificationChange);
    _conectividadProvider.dispose();
    _modeloManager.dispose();
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _notifProvider),
        ChangeNotifierProvider.value(value: _conectividadProvider),
        ChangeNotifierProvider(
          create: (_) => TramitesProvider(
            _tramitesRepo,
            _solicitudesRepo,
            _outboxRepo,
            _fileStorage,
            _syncManager,
            _apiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SolicitudesProvider(
            _solicitudesRepo,
            _syncManager,
            _apiService,
            _archivosRepo,
            _fileStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AgenteTramitesProvider(
            AgenteTramitesService(_apiService),
            _tramitesRepo,
            _asistenteLocal,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Trámites App',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routerConfig: _router,
      ),
    );
  }
}
