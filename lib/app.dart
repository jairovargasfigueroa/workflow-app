import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/config/routes.dart';
import 'package:tramites_app/config/theme.dart';
import 'package:tramites_app/providers/auth_provider.dart';
import 'package:tramites_app/providers/notification_provider.dart';
import 'package:tramites_app/providers/solicitudes_provider.dart';
import 'package:tramites_app/providers/tramites_provider.dart';
import 'package:tramites_app/services/api_service.dart';
import 'package:tramites_app/services/auth_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ApiService _apiService;
  late final AuthProvider _authProvider;
  late final NotificationProvider _notifProvider;
  late final GoRouter _router;
  bool _notifInitialized = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authProvider = AuthProvider(AuthService(), _apiService);
    _notifProvider = NotificationProvider(_apiService);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _notifProvider),
        ChangeNotifierProvider(create: (_) => TramitesProvider(_apiService)),
        ChangeNotifierProvider(create: (_) => SolicitudesProvider(_apiService)),
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
