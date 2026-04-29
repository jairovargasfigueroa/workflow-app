import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._apiService);

  final ApiService _apiService;
  final NotificationService _notificationService = NotificationService();

  bool _initialized = false;
  String? _pendingRoute;
  StreamSubscription<String>? _tokenRefreshSub;

  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  Future<void> init(String userId) async {
    if (_initialized) return;
    _initialized = true;

    await _notificationService.init(onTap: _onNotificationTap);

    final token = await _notificationService.getToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('[NOTIF] FCM token obtenido');
      await _apiService.registerFcmToken(userId, token);
    }

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _notificationService.onTokenRefresh.listen((newToken) {
      debugPrint('[NOTIF] FCM token refrescado');
      _apiService.registerFcmToken(userId, newToken);
    });
  }

  void reset() {
    _initialized = false;
    _pendingRoute = null;
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }

  void _onNotificationTap(Map<String, dynamic> data) {
    final solicitudId = data['solicitudId'];
    if (solicitudId == null) return;
    _pendingRoute = '/solicitudes/$solicitudId';
    notifyListeners();
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    super.dispose();
  }
}
