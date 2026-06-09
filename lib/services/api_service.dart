import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tramites_app/models/archivo_response.dart';
import 'package:tramites_app/models/documento_kit.dart';
import 'package:tramites_app/models/tramite.dart';

class ApiService {
  // static const String _baseUrl = 'https://api.workflow-tramites.site:8443';
  static const String _baseUrl = 'http://192.168.0.10:8080';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  /// Cliente Dio compartido (incluye el header Authorization ya inyectado).
  /// Lo reutilizan otros servicios para no duplicar configuración de auth.
  Dio get dio => _dio;

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<void> registerFcmToken(String userId, String token) async {
    try {
      await _dio.patch(
        '/api/usuarios/$userId/fcm-token',
        data: {'token': token},
      );
    } catch (e) {
      debugPrint('[API] Error registrando FCM token: $e');
    }
  }

  Future<List<TramiteDisponible>> getTramites() async {
    try {
      debugPrint('[API] GET /api/tramites');
      final response = await _dio.get('/api/tramites');
      final data = response.data as List<dynamic>;
      return data
          .map(
            (json) => TramiteDisponible.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      debugPrint('[API] DioException getTramites: ${e.type}');
      throw Exception(_mensajeError(e));
    }
  }

  Future<List<DocumentoKit>> getDocumentosKit(String tramiteId) async {
    try {
      debugPrint('[API] GET /api/tramites/$tramiteId/documentos-kit');
      final response =
          await _dio.get('/api/tramites/$tramiteId/documentos-kit');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => DocumentoKit.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[API] DioException getDocumentosKit: ${e.type}');
      throw Exception(_mensajeError(e));
    }
  }

  Future<FormularioTemplate> getFormulario(String formularioId) async {
    try {
      debugPrint('[API] GET /api/formularios/$formularioId');
      final response = await _dio.get('/api/formularios/$formularioId');
      return FormularioTemplate.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[API] DioException getFormulario: ${e.type}');
      throw Exception(_mensajeError(e));
    }
  }

  Future<SolicitudDetalle> createSolicitud({
    required String tramiteId,
    required List<Map<String, String>> respuestasSolicitante,
  }) async {
    try {
      debugPrint('[API] POST /api/solicitudes');
      final response = await _dio.post(
        '/api/solicitudes',
        data: {
          'tramiteId': tramiteId,
          'respuestasSolicitante': respuestasSolicitante,
          'adjuntos': [],
        },
      );
      return SolicitudDetalle.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[API] DioException createSolicitud: ${e.type}');
      debugPrint('[API] Response: ${e.response?.data}');
      throw Exception(_mensajeError(e));
    }
  }

  Future<List<SolicitudResumen>> getMisSolicitudes() async {
    try {
      debugPrint('[API] GET /api/solicitudes/mis-solicitudes');
      final response = await _dio.get('/api/solicitudes/mis-solicitudes');
      final data = response.data as List<dynamic>;
      return data
          .map(
            (json) => SolicitudResumen.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      debugPrint('[API] DioException getMisSolicitudes: ${e.type}');
      throw Exception(_mensajeError(e));
    }
  }

  Future<SolicitudDetalle> getSolicitud(String id) async {
    try {
      debugPrint('[API] GET /api/solicitudes/$id');
      final response = await _dio.get('/api/solicitudes/$id');
      return SolicitudDetalle.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[API] DioException getSolicitud: ${e.type}');
      throw Exception(_mensajeError(e));
    }
  }

  // --- Archivos del módulo documental -----------------------------------

  /// Sube un archivo a una solicitud ya creada.
  /// `campoFormulario` = nombre del documento del kit (ej: "Cédula").
  Future<void> subirArchivo({
    required String solicitudId,
    required String campoFormulario,
    required String filePath,
    required String fileName,
    String? contentType,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      debugPrint('[API] POST /api/archivos/upload ($campoFormulario)');
      final formData = FormData.fromMap({
        'solicitudId': solicitudId,
        'campoFormulario': campoFormulario,
        'departamentoOrigenId': '',
        'archivo': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: _mediaType(contentType, fileName),
        ),
      });

      await _dio.post(
        '/api/archivos/upload',
        data: formData,
        // Tiempos amplios: los videos pueden tardar.
        options: Options(
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 2),
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      debugPrint('[API] DioException subirArchivo: ${e.type} ${e.response?.statusCode}');
      throw Exception(_mensajeError(e));
    }
  }

  /// Lista los archivos de una solicitud (ya filtrados por permisos del server).
  Future<List<ArchivoResponse>> getArchivosDeSolicitud(String solicitudId) async {
    try {
      debugPrint('[API] GET /api/archivos/solicitud/$solicitudId');
      final response = await _dio.get('/api/archivos/solicitud/$solicitudId');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => ArchivoResponse.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[API] DioException getArchivosDeSolicitud: ${e.type}');
      throw Exception(_mensajeError(e));
    }
  }

  /// Obtiene la URL presigned (S3) para ver/descargar un archivo.
  /// `attachment: false` → ver inline; `true` → descargar.
  /// El JWT solo se usa acá; la URL devuelta se abre sin token.
  Future<String> getUrlDescarga(String archivoId, {bool attachment = false}) async {
    try {
      debugPrint('[API] GET /api/archivos/$archivoId/descargar?attachment=$attachment');
      final response = await _dio.get(
        '/api/archivos/$archivoId/descargar',
        queryParameters: {'attachment': attachment},
      );
      final data = response.data as Map<String, dynamic>;
      final url = data['urlDescarga']?.toString();
      if (url == null || url.isEmpty) {
        throw Exception('El servidor no devolvió la URL de descarga.');
      }
      return url;
    } on DioException catch (e) {
      debugPrint('[API] DioException getUrlDescarga: ${e.type} ${e.response?.statusCode}');
      if (e.response?.statusCode == 403) {
        throw Exception('No tenés permiso para ver este documento.');
      }
      throw Exception(_mensajeError(e));
    }
  }

  /// Deriva el MediaType (content-type) a partir del content-type dado o la
  /// extensión del archivo. Si no lo reconoce, usa application/octet-stream.
  MediaType _mediaType(String? contentType, String fileName) {
    if (contentType != null && contentType.contains('/')) {
      try {
        return MediaType.parse(contentType);
      } catch (_) {/* sigue por extensión */}
    }
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    const mapa = {
      'pdf': ['application', 'pdf'],
      'jpg': ['image', 'jpeg'],
      'jpeg': ['image', 'jpeg'],
      'png': ['image', 'png'],
      'gif': ['image', 'gif'],
      'webp': ['image', 'webp'],
      'mp4': ['video', 'mp4'],
      'mov': ['video', 'quicktime'],
      'doc': ['application', 'msword'],
      'docx': [
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document'
      ],
      'xls': ['application', 'vnd.ms-excel'],
      'xlsx': [
        'application',
        'vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      ],
    };
    final par = mapa[ext];
    return par != null
        ? MediaType(par[0], par[1])
        : MediaType('application', 'octet-stream');
  }

  String _mensajeError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Verifica tu conexión.';
      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor.';
      case DioExceptionType.badResponse:
        final codigo = e.response?.statusCode;
        return 'Error del servidor (código $codigo).';
      default:
        return e.message ?? 'Error desconocido.';
    }
  }
}
