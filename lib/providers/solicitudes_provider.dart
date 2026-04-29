import 'package:flutter/foundation.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/services/api_service.dart';

class SolicitudesProvider extends ChangeNotifier {
  final ApiService _apiService;

  SolicitudesProvider(this._apiService);

  List<SolicitudResumen> _solicitudes = [];
  SolicitudDetalle? _solicitudSeleccionada;
  bool _isLoadingLista = false;
  bool _isLoadingDetalle = false;
  String? _errorLista;
  String? _errorDetalle;

  List<SolicitudResumen> get solicitudes => _solicitudes;
  SolicitudDetalle? get solicitudSeleccionada => _solicitudSeleccionada;
  bool get isLoadingLista => _isLoadingLista;
  bool get isLoadingDetalle => _isLoadingDetalle;
  String? get errorLista => _errorLista;
  String? get errorDetalle => _errorDetalle;

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
}
