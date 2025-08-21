import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:puvi/firebase_options.dart';
import 'package:puvi/main.dart';
import 'package:puvi/src/models/usernotification.dart';
import 'package:universal_html/html.dart' as html;

/// Handles all Firebase + Notifications functionality
class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  /// Initialize Firebase and FCM
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // _requestPermission();
    // await _getToken();
    _getToken();
    _setupForegroundListener();

    // ✅ Background messages must be set early
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  /// Request Web Notification permission
  static Future<void> askNotificationPermission() async {
    final asked = html.window.localStorage['notifAsked'];
    if (asked == 'true') return; // ✅ already asked before

    if (html.Notification.supported) {
      final permission = await html.Notification.requestPermission();

      if (permission == "granted") {
        print("✅ Notifications allowed by user");
      } else {
        print("❌ Notifications denied by user");
        html.window.alert(
            "⚠️ Notifications are required to receive important order updates. "
            "Please enable them in your browser settings.");
      }

      html.window.localStorage['notifAsked'] = 'true'; // ✅ save flag
    }
  }

  /// Get or refresh FCM token
  static Future<String?> _getToken() async {
    _fcmToken = await   _messaging.getToken(
      vapidKey:
          'BFFJUELo-1JO391-0H_4ov3qVlrIPjtaNLQQUDRXlR8WNIY4JLj-vood7JrOAbqV0uLawprzm6_2qZVJRg2M8ts',
    );
    print('🔑 FCM Token: $_fcmToken');
    return _fcmToken;
  }

  /// Get current token
  static String? get token => _fcmToken;

  /// Foreground messages
  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = UserNotification.fromFCM(message);

      // ✅ Add to controller + cache
      notificationController.addNotification(notif, saveToCache: true);

      // ✅ Show browser notification (only on Web)
      if (kIsWeb && html.Notification.permission == 'granted') {
        html.Notification(
          message.notification?.title ?? 'PuviPure',
          body: message.notification?.body ?? '',
          icon: 'assets/icons/appicon.png',
        );
      }
    });
  }

  /// Background message handler
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final notif = UserNotification.fromFCM(message);

    // ✅ Save to local cache so reload can show it
    notificationController.addNotification(notif, saveToCache: true);

    print('📩 Background message: ${message.messageId}');
  }
}
