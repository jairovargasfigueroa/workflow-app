import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tramites_app/services/api_service.dart';
import 'package:tramites_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  AuthProvider(this._authService, this._apiService) {
    // Si el server rechaza por 401 (token expirado/ inválido), cerrar sesión.
    _apiService.onUnauthorized = () {
      if (_isLoggedIn) {
        debugPrint('[AUTH] 401 del server → cerrando sesión');
        logout();
      }
    };
  }

  bool _isLoggedIn = false;
  String? _userId;
  String? _email;
  String? _nombre;
  String? _rol;
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get email => _email;
  String? get nombre => _nombre;
  String? get rol => _rol;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Restaura la sesión desde storage al arrancar la app.
  Future<void> init() async {
    final token = await _storage.read(key: 'jwt_token');
    final userId = await _storage.read(key: 'user_id');
    final email = await _storage.read(key: 'user_email');
    final nombre = await _storage.read(key: 'user_nombre');
    final rol = await _storage.read(key: 'user_rol');

    if (token != null && userId != null) {
      // No restaurar una sesión con token vencido: limpiar y quedar en login.
      if (_tokenVencido(token)) {
        debugPrint('[AUTH] Token guardado vencido → limpiando sesión');
        await _storage.deleteAll();
        _apiService.setAuthToken(null);
        return;
      }
      _apiService.setAuthToken(token);
      _isLoggedIn = true;
      _userId = userId;
      _email = email;
      _nombre = nombre;
      _rol = rol;
      notifyListeners();
    }
  }

  /// Decodifica el `exp` del JWT y dice si ya venció.
  /// Si el token no es un JWT decodificable o no trae `exp`, no bloquea
  /// (devuelve false) para no romper sesiones válidas.
  bool _tokenVencido(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final json =
          jsonDecode(utf8.decode(base64.decode(payload))) as Map<String, dynamic>;
      final exp = json['exp'];
      if (exp is! int) return false;
      final vencimiento = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(vencimiento);
    } catch (_) {
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      await _storage.write(key: 'jwt_token', value: response.token);
      await _storage.write(key: 'user_id', value: response.id);
      await _storage.write(key: 'user_email', value: response.email);
      await _storage.write(key: 'user_nombre', value: response.nombre);
      await _storage.write(key: 'user_rol', value: response.rol);

      _apiService.setAuthToken(response.token);
      _isLoggedIn = true;
      _userId = response.id;
      _email = response.email;
      _nombre = response.nombre;
      _rol = response.rol;
      debugPrint('[AUTH] Login exitoso: ${response.id} (${response.rol})');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[AUTH] Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _apiService.setAuthToken(null);
    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _nombre = null;
    _rol = null;
    notifyListeners();
  }
}
