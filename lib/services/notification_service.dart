import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannelId = 'tramites_channel';
  static const _androidChannelName = 'Trámites';
  static const _androidChannelDesc = 'Notificaciones de cambios en trámites';

  /// Inicializa permisos, notificaciones locales y los tres handlers de FCM.
  /// [onTap] se llama con el data payload cuando el usuario toca una notificación.
  Future<void> init({required void Function(Map<String, dynamic>) onTap}) async {
    await _requestPermissions();
    await _initLocalNotifications(onTap: onTap);
    _setupForegroundHandler();
    _setupBackgroundTapHandler(onTap: onTap);
    await _checkInitialMessage(onTap: onTap);
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  // ---------------------------------------------------------------------------

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // En Android 13+ FCM necesita que el canal exista antes de mostrar notifs.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _androidChannelId,
            _androidChannelName,
            description: _androidChannelDesc,
            importance: Importance.high,
          ),
        );
  }

  Future<void> _initLocalNotifications({
    required void Function(Map<String, dynamic>) onTap,
  }) async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // El usuario tocó la notificación local (foreground).
        if (details.payload != null) {
          try {
            final data =
                jsonDecode(details.payload!) as Map<String, dynamic>;
            onTap(data);
          } catch (e) {
            debugPrint('[NOTIF] Payload inválido: $e');
          }
        }
      },
    );
  }

  /// App en foreground: FCM no muestra nada — lo mostramos nosotros.
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('[FCM FG] ${message.notification?.title}');
      await _showLocalNotification(message);
    });
  }

  /// App en background: el SO ya mostró la notif, pero necesitamos el tap.
  void _setupBackgroundTapHandler({
    required void Function(Map<String, dynamic>) onTap,
  }) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM BG TAP] ${message.data}');
      onTap(message.data);
    });
  }

  /// App terminada: detecta si fue abierta tocando una notificación.
  Future<void> _checkInitialMessage({
    required void Function(Map<String, dynamic>) onTap,
  }) async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM INITIAL] ${initial.data}');
      onTap(initial.data);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: androidDetails),
      payload: jsonEncode(message.data),
    );
  }
}
