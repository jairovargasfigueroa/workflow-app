import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tramites_app/data/local/file_storage_service.dart';
import 'package:tramites_app/data/repositories/outbox_repository.dart';
import 'package:tramites_app/data/repositories/solicitudes_repository.dart';
import 'package:tramites_app/data/repositories/tramites_repository.dart';
import 'package:tramites_app/data/sync/sync_manager.dart';
import 'package:tramites_app/models/archivo_para_subir.dart';
import 'package:tramites_app/models/documento_kit.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/services/api_service.dart';
import 'package:uuid/uuid.dart';

/// Estado de trámites/formularios. Offline-first: **lee de Drift** (vía repo).
/// Crear una solicitud **encola** en el Outbox (funciona offline) y el
/// SyncManager la sube cuando hay internet.
class TramitesProvider extends ChangeNotifier {
  final TramitesRepository _repo;
  final SolicitudesRepository _solicitudesRepo;
  final OutboxRepository _outboxRepo;
  final FileStorageService _fileStorage;
  final SyncManager _sync;
  final ApiService _api;
  final _uuid = const Uuid();

  late final StreamSubscription _tramitesSub;

  TramitesProvider(
    this._repo,
    this._solicitudesRepo,
    this._outboxRepo,
    this._fileStorage,
    this._sync,
    this._api,
  ) {
    _tramitesSub = _repo.watchTramites().listen((lista) {
      _tramites = lista;
      notifyListeners();
    });
  }

  List<TramiteDisponible> _tramites = [];
  FormularioTemplate? _formulario;
  List<DocumentoKit> _documentosKit = [];
  bool _sincronizandoTramites = false;
  bool _isLoadingFormulario = false;
  bool _isLoadingKit = false;
  bool _isSubmitting = false;
  String? _error;
  String? _errorFormulario;
  String? _errorKit;
  String? _errorSubmit;

  List<TramiteDisponible> get tramites =>
      _tramites.where((t) => t.activo).toList();
  FormularioTemplate? get formulario => _formulario;
  List<DocumentoKit> get documentosKit => _documentosKit;
  bool get isLoadingTramites => _sincronizandoTramites && _tramites.isEmpty;
  bool get isLoadingFormulario => _isLoadingFormulario;
  bool get isLoadingKit => _isLoadingKit;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get errorFormulario => _errorFormulario;
  String? get errorKit => _errorKit;
  String? get errorSubmit => _errorSubmit;

  @override
  void dispose() {
    _tramitesSub.cancel();
    super.dispose();
  }

  Future<void> loadTramites() async {
    _error = null;
    _sincronizandoTramites = true;
    notifyListeners();
    final ok = await _sync.sincronizarTramites();
    _sincronizandoTramites = false;
    if (!ok && _tramites.isEmpty) {
      _error = 'No se pudieron cargar los trámites. Revisá tu conexión.';
    }
    notifyListeners();
  }

  Future<void> loadFormulario(String formularioId) async {
    _isLoadingFormulario = true;
    _errorFormulario = null;
    notifyListeners();

    _formulario = await _repo.getFormulario(formularioId);
    if (_formulario != null) notifyListeners();

    try {
      final fresco = await _api.getFormulario(formularioId);
      await _repo.guardarFormulario(fresco);
      _formulario = fresco;
    } catch (e) {
      if (_formulario == null) {
        _errorFormulario = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isLoadingFormulario = false;
      notifyListeners();
    }
  }

  Future<void> loadDocumentosKit(String tramiteId) async {
    _isLoadingKit = true;
    _errorKit = null;
    _documentosKit = [];
    notifyListeners();

    _documentosKit = await _repo.getKit(tramiteId);
    if (_documentosKit.isNotEmpty) notifyListeners();

    try {
      final fresco = await _api.getDocumentosKit(tramiteId);
      await _repo.guardarKit(tramiteId, fresco);
      _documentosKit = fresco;
    } catch (e) {
      if (_documentosKit.isEmpty) {
        _errorKit = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isLoadingKit = false;
      notifyListeners();
    }
  }

  /// Crea una solicitud: la **encola** en el Outbox (funciona online y offline).
  /// Guarda los archivos en disco + una solicitud local "pendiente" y dispara
  /// el sync (best-effort). Devuelve true si quedó encolada.
  Future<bool> crearSolicitudConKit({
    required String tramiteId,
    String? tramiteNombre,
    required List<Map<String, String>> respuestas,
    required List<ArchivoParaSubir> archivos,
  }) async {
    _isSubmitting = true;
    _errorSubmit = null;
    notifyListeners();
    try {
      final clientId = _uuid.v4();

      // 1) Copiar archivos a carpeta persistente (sobreviven hasta subir).
      //    Cada archivo lleva su PROPIO clientId (operación distinta del crear
      //    y de los demás archivos) → el back deduplica cada uno por separado.
      final archivosLocales = <Map<String, dynamic>>[];
      for (final a in archivos) {
        final ruta = await _fileStorage.guardarParaSubir(clientId, a);
        archivosLocales.add({
          'campo': a.campoFormulario,
          'pathLocal': ruta,
          'nombre': a.nombre,
          'clientId': _uuid.v4(),
        });
      }

      // 2) Solicitud local "pendiente" (aparece en la lista con badge).
      await _solicitudesRepo.insertarPendiente(
        clientId: clientId,
        tramiteId: tramiteId,
        tramiteNombre: tramiteNombre,
      );

      // 3) Encolar en el Outbox.
      await _outboxRepo.encolarCrearSolicitud(
        clientId: clientId,
        tramiteId: tramiteId,
        respuestas: respuestas,
        archivos: archivosLocales,
      );

      // 4) Intentar subir ya (best-effort; si está offline, queda en la cola).
      _sync.procesarOutbox();
      return true;
    } catch (e) {
      _errorSubmit = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[TRAMITES] Error encolando solicitud: $_errorSubmit');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
