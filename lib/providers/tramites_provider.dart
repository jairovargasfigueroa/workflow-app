import 'package:flutter/foundation.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/services/api_service.dart';

class TramitesProvider extends ChangeNotifier {
  final ApiService _apiService;

  TramitesProvider(this._apiService);

  List<TramiteDisponible> _tramites = [];
  FormularioTemplate? _formulario;
  bool _isLoadingTramites = false;
  bool _isLoadingFormulario = false;
  bool _isSubmitting = false;
  String? _error;
  String? _errorFormulario;
  String? _errorSubmit;

  List<TramiteDisponible> get tramites =>
      _tramites.where((t) => t.activo).toList();
  FormularioTemplate? get formulario => _formulario;
  bool get isLoadingTramites => _isLoadingTramites;
  bool get isLoadingFormulario => _isLoadingFormulario;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get errorFormulario => _errorFormulario;
  String? get errorSubmit => _errorSubmit;

  Future<void> loadTramites() async {
    _isLoadingTramites = true;
    _error = null;
    notifyListeners();
    try {
      _tramites = await _apiService.getTramites();
      debugPrint('[TRAMITES] Cargados: ${_tramites.length}');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[TRAMITES] Error: $_error');
    } finally {
      _isLoadingTramites = false;
      notifyListeners();
    }
  }

  Future<void> loadFormulario(String formularioId) async {
    _isLoadingFormulario = true;
    _errorFormulario = null;
    _formulario = null;
    notifyListeners();
    try {
      _formulario = await _apiService.getFormulario(formularioId);
      debugPrint('[TRAMITES] Formulario cargado: ${_formulario?.id}');
    } catch (e) {
      _errorFormulario = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[TRAMITES] Error formulario: $_errorFormulario');
    } finally {
      _isLoadingFormulario = false;
      notifyListeners();
    }
  }

  Future<SolicitudDetalle?> createSolicitud({
    required String tramiteId,
    required List<Map<String, String>> respuestas,
  }) async {
    _isSubmitting = true;
    _errorSubmit = null;
    notifyListeners();
    try {
      final result = await _apiService.createSolicitud(
        tramiteId: tramiteId,
        respuestasSolicitante: respuestas,
      );
      debugPrint('[TRAMITES] Solicitud creada: ${result.id}');
      return result;
    } catch (e) {
      _errorSubmit = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[TRAMITES] Error creando solicitud: $_errorSubmit');
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
