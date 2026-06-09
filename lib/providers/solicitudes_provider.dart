import 'package:flutter/foundation.dart';
import 'package:tramites_app/models/archivo_response.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/services/api_service.dart';

class SolicitudesProvider extends ChangeNotifier {
  final ApiService _apiService;

  SolicitudesProvider(this._apiService);

  List<SolicitudResumen> _solicitudes = [];
  SolicitudDetalle? _solicitudSeleccionada;
  List<ArchivoResponse> _archivos = [];
  bool _isLoadingLista = false;
  bool _isLoadingDetalle = false;
  bool _isLoadingArchivos = false;
  String? _errorLista;
  String? _errorDetalle;
  String? _errorArchivos;

  List<SolicitudResumen> get solicitudes => _solicitudes;
  SolicitudDetalle? get solicitudSeleccionada => _solicitudSeleccionada;
  List<ArchivoResponse> get archivos => _archivos;
  bool get isLoadingLista => _isLoadingLista;
  bool get isLoadingDetalle => _isLoadingDetalle;
  bool get isLoadingArchivos => _isLoadingArchivos;
  String? get errorLista => _errorLista;
  String? get errorDetalle => _errorDetalle;
  String? get errorArchivos => _errorArchivos;

  Future<void> loadMisSolicitudes() async {
    _isLoadingLista = true;
    _errorLista = null;
    notifyListeners();
    try {
      _solicitudes = await _apiService.getMisSolicitudes();
      debugPrint('[SOLICITUDES] Cargadas: ${_solicitudes.length}');
    } catch (e) {
      _errorLista = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[SOLICITUDES] Error lista: $_errorLista');
    } finally {
      _isLoadingLista = false;
      notifyListeners();
    }
  }

  Future<void> loadSolicitud(String id) async {
    _isLoadingDetalle = true;
    _errorDetalle = null;
    _solicitudSeleccionada = null;
    notifyListeners();
    try {
      _solicitudSeleccionada = await _apiService.getSolicitud(id);
      debugPrint('[SOLICITUDES] Detalle cargado: ${_solicitudSeleccionada?.id}');
    } catch (e) {
      _errorDetalle = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[SOLICITUDES] Error detalle: $_errorDetalle');
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  /// Carga los archivos de una solicitud (el server filtra por permisos).
  Future<void> loadArchivos(String solicitudId) async {
    _isLoadingArchivos = true;
    _errorArchivos = null;
    _archivos = [];
    notifyListeners();
    try {
      _archivos = await _apiService.getArchivosDeSolicitud(solicitudId);
      debugPrint('[SOLICITUDES] Archivos: ${_archivos.length}');
    } catch (e) {
      _errorArchivos = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[SOLICITUDES] Error archivos: $_errorArchivos');
    } finally {
      _isLoadingArchivos = false;
      notifyListeners();
    }
  }

  /// Obtiene la URL presigned para ver/descargar (la abre el caller).
  Future<String> obtenerUrlDescarga(String archivoId, {bool attachment = false}) {
    return _apiService.getUrlDescarga(archivoId, attachment: attachment);
  }
}
