import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tramites_app/models/tramite.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.0.16:8080';

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
          .map((json) =>
              TramiteDisponible.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[API] DioException getTramites: ${e.type}');
      throw Exception(_mensajeError(e));
    }
  }

  Future<FormularioTemplate> getFormulario(String formularioId) async {
    try {
      debugPrint('[API] GET /api/formularios/$formularioId');
      final response = await _dio.get('/api/formularios/$formularioId');
      return FormularioTemplate.fromJson(
          response.data as Map<String, dynamic>);
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
          .map((json) =>
              SolicitudResumen.fromJson(json as Map<String, dynamic>))
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
