import 'package:flutter/foundation.dart';
import 'package:tramites_app/models/archivo_para_subir.dart';
import 'package:tramites_app/models/documento_kit.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/services/api_service.dart';

class TramitesProvider extends ChangeNotifier {
  final ApiService _apiService;

  TramitesProvider(this._apiService);

  List<TramiteDisponible> _tramites = [];
  FormularioTemplate? _formulario;
  List<DocumentoKit> _documentosKit = [];
  bool _isLoadingTramites = false;
  bool _isLoadingFormulario = false;
  bool _isLoadingKit = false;
  bool _isSubmitting = false;
  String? _error;
  String? _errorFormulario;
  String? _errorKit;
  String? _errorSubmit;
  String? _estadoSubida;

  /// solicitudId ya creado, para no recrear la solicitud si un reintento de
  /// subida vuelve a entrar (evita solicitudes duplicadas).
  String? _solicitudCreadaId;

  List<TramiteDisponible> get tramites =>
      _tramites.where((t) => t.activo).toList();
  FormularioTemplate? get formulario => _formulario;
  List<DocumentoKit> get documentosKit => _documentosKit;
  bool get isLoadingTramites => _isLoadingTramites;
  bool get isLoadingFormulario => _isLoadingFormulario;
  bool get isLoadingKit => _isLoadingKit;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get errorFormulario => _errorFormulario;
  String? get errorKit => _errorKit;
  String? get errorSubmit => _errorSubmit;
  String? get estadoSubida => _estadoSubida;

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

  Future<void> loadDocumentosKit(String tramiteId) async {
    _isLoadingKit = true;
    _errorKit = null;
    _documentosKit = [];
    notifyListeners();
    try {
      _documentosKit = await _apiService.getDocumentosKit(tramiteId);
      debugPrint('[TRAMITES] Kit cargado: ${_documentosKit.length} documentos');
    } catch (e) {
      _errorKit = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[TRAMITES] Error kit: $_errorKit');
    } finally {
      _isLoadingKit = false;
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

  /// Crea la solicitud y sube los archivos del kit.
  ///
  /// Devuelve:
  /// - `null` si falló la creación (no se subió nada).
  /// - `[]` si se creó y se subieron todos los archivos.
  /// - `[campos...]` con los documentos que NO se pudieron subir (la solicitud
  ///   sí se creó). En un reintardo, no se vuelve a crear (usa `_solicitudCreadaId`).
  Future<List<String>?> crearSolicitudConKit({
    required String tramiteId,
    required List<Map<String, String>> respuestas,
    required List<ArchivoParaSubir> archivos,
  }) async {
    _isSubmitting = true;
    _errorSubmit = null;
    _estadoSubida = null;
    notifyListeners();

    try {
      // 1) Crear (solo si no se creó ya en un intento anterior).
      if (_solicitudCreadaId == null) {
        _estadoSubida = 'Creando solicitud…';
        notifyListeners();
        final solicitud = await _apiService.createSolicitud(
          tramiteId: tramiteId,
          respuestasSolicitante: respuestas,
        );
        _solicitudCreadaId = solicitud.id;
        debugPrint('[TRAMITES] Solicitud creada: ${solicitud.id}');
      }

      // 2) Subir cada archivo; juntar los que fallen.
      final fallidos = <String>[];
      for (var i = 0; i < archivos.length; i++) {
        final a = archivos[i];
        try {
          await _apiService.subirArchivo(
            solicitudId: _solicitudCreadaId!,
            campoFormulario: a.campoFormulario,
            filePath: a.path,
            fileName: a.nombre,
            onSendProgress: (enviado, total) {
              if (total > 0) {
                final pct = (enviado / total * 100).clamp(0, 100).toStringAsFixed(0);
                _estadoSubida =
                    'Subiendo ${a.campoFormulario} (${i + 1}/${archivos.length})… $pct%';
                notifyListeners();
              }
            },
          );
        } catch (e) {
          debugPrint('[TRAMITES] Falló subir ${a.campoFormulario}: $e');
          fallidos.add(a.campoFormulario);
        }
      }

      if (fallidos.isEmpty) {
        _solicitudCreadaId = null; // listo, limpiamos para una próxima solicitud
        return [];
      } else {
        _errorSubmit =
            'La solicitud se creó, pero no se pudieron subir: ${fallidos.join(', ')}. Tocá Enviar para reintentar.';
        return fallidos;
      }
    } catch (e) {
      _errorSubmit = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[TRAMITES] Error en crearSolicitudConKit: $_errorSubmit');
      return null;
    } finally {
      _estadoSubida = null;
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
