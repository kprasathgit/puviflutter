import 'dart:convert';

import 'package:puvi/src/models/usernotification.dart';
import 'package:universal_html/html.dart' as html;

class IndexedDBHelper {
  static const _storagePrefix = "puvi_notifications_";

  /// Build per-user key
  static String _keyFor(String uid) => '$_storagePrefix$uid';

  /// Save all notifications for a user
  static Future<void> saveAllForUser(String uid, List<UserNotification> list) async {
    final data = list.map((n) => n.toMap()).toList();
    html.window.localStorage[_keyFor(uid)] = jsonEncode(data);
  }

  /// Save a single notification for a user (prepend to cache)
  static Future<void> saveNotificationForUser(String uid, UserNotification notif) async {
    final current = await loadNotificationsForUser(uid);
    current.insert(0, notif);
    await saveAllForUser(uid, current);
  }

  /// Load cached notifications for a user
  static Future<List<UserNotification>> loadNotificationsForUser(String uid) async {
    final raw = html.window.localStorage[_keyFor(uid)];
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => UserNotification.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Clear cache for a specific user
  static void clearForUser(String uid) {
    html.window.localStorage.remove(_keyFor(uid));
  }

  /// Clear all users' caches
  static void clearAll() {
    final keysToRemove = html.window.localStorage.keys
        .where((key) => key.startsWith(_storagePrefix))
        .toList();
    for (final key in keysToRemove) {
      html.window.localStorage.remove(key);
    }
  }
}
