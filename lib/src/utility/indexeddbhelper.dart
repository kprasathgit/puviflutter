import 'dart:convert';
import 'package:puvi/src/models/usernotification.dart';
import 'package:universal_html/html.dart' as html;

class IndexedDBHelper {
  static const _storageKey = "puvi_notifications";

  /// Save all notifications
  static Future<void> saveAll(List<UserNotification> list) async {
    final data = list.map((n) => n.toMap()).toList();
    html.window.localStorage[_storageKey] = jsonEncode(data);
  }

  /// Save a single notification (append to cache)
  static Future<void> saveNotification(UserNotification notif) async {
    final current = await loadNotifications();
    current.insert(0, notif);
    saveAll(current);
  }

  /// Load cached notifications
  static Future<List<UserNotification>> loadNotifications() async {
    final raw = html.window.localStorage[_storageKey];
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => UserNotification.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Clear cache
  static void clear() {
    html.window.localStorage.remove(_storageKey);
  }
}
