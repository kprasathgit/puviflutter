import 'package:flutter/foundation.dart';
import 'package:puvi/src/common/apiservice.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/src/models/usernotification.dart';
import 'package:puvi/src/notification/notification.service.dart';
import 'package:puvi/src/utility/indexeddbhelper.dart';

class NotificationController with ChangeNotifier {
  final NotificationService notificationService;
  NotificationController(this.notificationService);

  List<UserNotification> _notifications = [];
  List<UserNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.seen).length;

  /// Add new notification (from FCM or SW foreground)
  void addNotification(UserNotification notification,
      {bool saveToCache = true}) {
    _notifications.insert(0, notification); // latest first
    notifyListeners();

    if (saveToCache) {
      IndexedDBHelper.saveNotification(notification);
    }
  }

  /// Mark all as seen
  void markAllSeen() {
    for (var n in _notifications) {
      n.seen = true;
    }
    notifyListeners();
    IndexedDBHelper.saveAll(_notifications);
  }

  /// Load cached notifications from IndexedDB (instant load on reload)
  Future<void> loadFromCache() async {
    final cached = await IndexedDBHelper.loadNotifications();
    if (cached.isNotEmpty) {
      _notifications = cached;
      notifyListeners();
    }
  }

  /// Fetch fresh notifications from backend (source of truth)
  Future<void> fetchFromNotificationServer(String uid) async {
    try {
      final result = await ApiService.get<List<UserNotification>>(
        url: '${Urls.fetchUsernotifications}/$uid',
        fromJson: (json) {
          // ✅ Look inside "returnObject"
          final list =
              (json as List).map((e) => UserNotification.fromMap(e)).toList();
          return list;
        },
      );

      if (result.status && result.returnObject != null) {
        final apiList = result.returnObject!;

        // ✅ Merge cached + backend
        final merged = {
          for (var n in _notifications) n.id: n,
          for (var n in apiList) n.id: n,
        }.values.toList();

        _notifications = merged;

        // ✅ Save merged to cache
        IndexedDBHelper.saveAll(_notifications);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Fetch notifications error: $e");
    }
  }
}
