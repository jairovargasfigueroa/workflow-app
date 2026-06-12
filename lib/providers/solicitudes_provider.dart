import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tramites_app/data/local/file_storage_service.dart';
import 'package:tramites_app/data/repositories/archivos_repository.dart';
import 'package:tramites_app/data/repositories/solicitudes_repository.dart';
import 'package:tramites_app/data/sync/sync_manager.dart';
import 'package:tramites_app/models/archivo_response.dart';
import 'package:tramites_app/models/solicitud_item.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/services/api_service.dart';

/// Estado de solicitudes. Offline-first: la **lista y el detalle se leen de
/// Drift**; el SyncManager los actualiza desde la API. Los archivos (ver online)
/// siguen yendo directo a la API (su versión offline es Off-4).
class SolicitudesProvider extends ChangeNotifier {
  final SolicitudesRepository _repo;
  final SyncManager _sync;
  final ApiService _api;
  final ArchivosRepository _archivosRepo;
  final FileStorageService _fileStorage;

  late final StreamSubscription _solicitudesSub;

  SolicitudesProvider(
    this._repo,
    this._sync,
    this._api,
    this._archivosRepo,
    this._fileStorage,
  ) {
    _solicitudesSub = _repo.watchSolicitudes().listen((lista) {
      _solicitudes = lista;
      notifyListeners();
    });
  }

  List<SolicitudItem> _solicitudes = [];
  SolicitudDetalle? _solicitudSeleccionada;
  List<ArchivoResponse> _archivos = [];
  bool _sincronizandoLista = false;
  bool _isLoadingDetalle = false;
  bool _isLoadingArchivos = false;
  String? _errorLista;
  String? _errorDetalle;
  String? _errorArchivos;

  List<SolicitudItem> get solicitudes => _solicitudes;
  SolicitudDetalle? get solicitudSeleccionada => _solicitudSeleccionada;
  List<ArchivoResponse> get archivos => _archivos;
  bool get isLoadingLista => _sincronizandoLista && _solicitudes.isEmpty;
  bool get isLoadingDetalle => _isLoadingDetalle;
  bool get isLoadingArchivos => _isLoadingArchivos;
  String? get errorLista => _errorLista;
  String? get errorDetalle => _errorDetalle;
  String? get errorArchivos => _errorArchivos;

  @override
  void dispose() {
    _solicitudesSub.cancel();
    super.dispose();
  }

  /// Refresca la lista desde el backend (best-effort). La lista se muestra
  /// siempre desde Drift; offline con cache → sin error.
  Future<void> loadMisSolicitudes() async {
    _errorLista = null;
    _sincronizandoLista = true;
    notifyListeners();
    // Primero intenta subir lo pendiente de la cola, luego baja el estado fresco.
    await _sync.procesarOutbox();
    final ok = await _sync.sincronizarSolicitudes();
    _sincronizandoLista = false;
    if (!ok && _solicitudes.isEmpty) {
      _errorLista =
          'No se pudieron cargar tus solicitudes. Revisá tu conexión.';
    }
    notifyListeners();
  }

  /// Reintenta enviar una solicitud que quedó en error (botón "Reintentar").
  Future<void> reintentarSolicitud(String clientId) {
    return _sync.reintentar(clientId);
  }

  /// Descarta una solicitud fallida (es solo local, nunca llegó al servidor):
  /// borra lo local + la cola + sus archivos. La lista se refresca sola (stream).
  Future<void> descartarSolicitud(String clientId) {
    return _sync.descartar(clientId);
  }

  /// Detalle: primero del cache (Drift), luego refresca desde la API.
  Future<void> loadSolicitud(String id) async {
    _isLoadingDetalle = true;
    _errorDetalle = null;
    notifyListeners();

    _solicitudSeleccionada = await _repo.getSolicitud(id);
    if (_solicitudSeleccionada != null) notifyListeners();

    try {
      final fresco = await _api.getSolicitud(id);
      await _repo.guardarDetalle(fresco);
      _solicitudSeleccionada = fresco;
    } catch (e) {
      if (_solicitudSeleccionada == null) {
        _errorDetalle = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  /// Archivos de la solicitud. Online: trae del server (filtra por permisos)
  /// y cachea la metadata. Offline: lee la metadata cacheada.
  Future<void> loadArchivos(String solicitudId) async {
    _isLoadingArchivos = true;
    _errorArchivos = null;
    notifyListeners();
    try {
      final frescos = await _api.getArchivosDeSolicitud(solicitudId);
      await _archivosRepo.guardarArchivos(solicitudId, frescos);
      _archivos = frescos;
    } catch (e) {
      // Offline o falla → mostrar lo cacheado.
      _archivos = await _archivosRepo.getArchivos(solicitudId);
      if (_archivos.isEmpty) {
        _errorArchivos = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isLoadingArchivos = false;
      notifyListeners();
    }
  }

  /// Devuelve la ruta local del archivo para abrirlo con el visor nativo.
  /// Si ya se descargó, la reutiliza (sirve offline). Si no, lo descarga
  /// (necesita internet la primera vez) y lo cachea.
  Future<String> prepararArchivoLocal(ArchivoResponse archivo) async {
    final existente = await _archivosRepo.getPathLocal(archivo.id);
    if (existente != null && await File(existente).exists()) {
      // Ya cacheado → marcarlo como usado recién (para el LRU) y reutilizar.
      unawaited(_fileStorage.tocar(existente));
      return existente;
    }
    final destino = await _fileStorage.rutaDescarga(archivo.id, archivo.nombre);
    await _api.descargarArchivoLocal(archivoId: archivo.id, destino: destino);
    await _archivosRepo.setPathLocal(archivo.id, destino);
    // Tras bajar uno nuevo, mantener la caché bajo el tope (en segundo plano).
    unawaited(_fileStorage.limpiarDescargas());
    return destino;
  }
}
