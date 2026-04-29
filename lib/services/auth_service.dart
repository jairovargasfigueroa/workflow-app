import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthResponse {
  final String token;
  final String id;
  final String email;
  final String nombre;
  final String rol;

  const AuthResponse({
    required this.token,
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
    );
  }
}

class AuthService {
  static const String _baseUrl = 'https://api.workflow-tramites.site:8443';

  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      debugPrint('[AUTH] POST /api/auth/login');
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
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
        final status = e.response?.statusCode;
        if (status == 401) return 'Correo o contraseña incorrectos.';
        return 'Error del servidor (código $status).';
      default:
        return e.message ?? 'Error desconocido.';
    }
  }
}
