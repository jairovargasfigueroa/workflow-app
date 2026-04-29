import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tramites_app/services/api_service.dart';
import 'package:tramites_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  AuthProvider(this._authService, this._apiService);

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
      _apiService.setAuthToken(token);
      _isLoggedIn = true;
      _userId = userId;
      _email = email;
      _nombre = nombre;
      _rol = rol;
      notifyListeners();
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
