// lib/src/common/notification_helper.dart
import 'dart:html' as html;

class NotificationHelper {
  /// Request browser notification permission
  static Future<void> requestPermission() async {
    // if (!html.Notification.supported) {
    //   html.window.alert("⚠️ Notifications are not supported on this browser.");
    //   return;
    // }

    final permission = await html.Notification.requestPermission();

    // if (permission == "granted") {
    //   html.window.alert("✅ Notifications enabled! You’ll get order updates.");
    // }

    if (permission == "denied") {
      remindToEnable();
    }
  }

  /// Show a reminder message if user has denied notifications
  static void remindToEnable() {
    html.window.alert("⚠️ Notifications are required to receive order updates. "
        "Please enable them in your browser settings.");
  }
}
