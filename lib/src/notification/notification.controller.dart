import 'package:flutter/foundation.dart';
import 'package:puvi/src/common/apiservice.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/src/models/usernotification.dart';
import 'package:puvi/src/notification/notification.service.dart';
import 'package:puvi/src/utility/indexeddbhelper.dart';

class NotificationController with ChangeNotifier {
  final NotificationService notificationService;
  NotificationController(this.notificationService) {
    // Automatically watch UID changes to clear notifications for old users
    StorageUtil.uidNotifier.addListener(() {
      final uid = StorageUtil.uid;
      if (uid == null) {
        // User logged out → clear notifications
        clearNotifications();
      } else {
        // New user logged in → load fresh notifications
        _initForUser(uid);
      }
    });
  }

  List<UserNotification> _notifications = [];
  List<UserNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.seen).length;

  /// Filter before saving (drop seen + older than 15 days)
  List<UserNotification> _filterForCache(List<UserNotification> list) {
    final cutoff = DateTime.now().subtract(const Duration(days: 15));
    return list
        .where((n) => !(n.seen && (n.createdtime?.isBefore(cutoff) ?? false)))
        .toList();
  }

  /// Initialize notifications for a new UID
  Future<void> _initForUser(String uid) async {
    // Clear old notifications in memory
    _notifications = [];
    notifyListeners();

    // Load cached notifications for the current user
    await loadFromCache();

    // Fetch fresh notifications from server
    await fetchFromNotificationServer(uid);
  }

  /// Add new notification (from FCM or SW foreground)
  Future<void> addNotification(UserNotification notification,
      {bool saveToCache = true}) async {
    _notifications.insert(0, notification); // latest first
    notifyListeners();

    if (saveToCache && StorageUtil.uid != null) {
      await IndexedDBHelper.saveAllForUser(
        StorageUtil.uid!,
        _filterForCache(_notifications),
      );
    }
  }

  /// Mark all notifications as seen
  Future<void> markAllSeen() async {
    final unseen = _notifications.where((n) => !n.seen).toList();
    if (unseen.isEmpty) return;

    for (var n in unseen) n.seen = true;
    notifyListeners();

    if (StorageUtil.uid != null) {
      await IndexedDBHelper.saveAllForUser(
        StorageUtil.uid!,
        _filterForCache(_notifications),
      );
    }

    try {
      if (StorageUtil.uid != null && StorageUtil.uid!.isNotEmpty) {
        final keys = unseen.map((n) => n.uniquekey).toList();
        ApiService.postRaw(
          url: "${Urls.markAsSeenUrl}?uid=${StorageUtil.uid}",
          body: keys,
          fromJson: (_) => null,
        );
      }
    } catch (e) {
      print("❌ Mark all seen failed: $e");
    }
  }

  /// Mark single notification as seen (on user tap)
  Future<void> markSeen(UserNotification n) async {
    if (n.seen) return;

    n.seen = true;
    notifyListeners();

    if (StorageUtil.uid != null) {
      await IndexedDBHelper.saveAllForUser(
        StorageUtil.uid!,
        _filterForCache(_notifications),
      );
    }

    try {
      if (StorageUtil.uid != null && StorageUtil.uid!.isNotEmpty) {
        ApiService.postRaw(
          url: "${Urls.markAsSeenUrl}?uid=${StorageUtil.uid}",
          body: [n.uniquekey],
          fromJson: (_) => null,
        );
      }
    } catch (e) {
      print("❌ Mark single notification seen failed: $e");
    }
  }

  /// Load cached notifications from IndexedDB (per-user)
  Future<void> loadFromCache() async {
    if (StorageUtil.uid == null) return;

    final cached =
        await IndexedDBHelper.loadNotificationsForUser(StorageUtil.uid!);
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
          final list =
              (json as List).map((e) => UserNotification.fromMap(e)).toList();
          return list;
        },
      );

      if (result.status && result.returnObject != null) {
        final apiList = result.returnObject!;

        // Merge by unique ID
        final merged = {
          for (var n in _notifications) n.id ?? n.uniquekey: n,
          for (var n in apiList) n.id ?? n.uniquekey: n,
        }.values.toList();

        // Sort latest first
        merged.sort((a, b) => (b.createdtime ?? DateTime(0))
            .compareTo(a.createdtime ?? DateTime(0)));

        _notifications = merged;

        // Save filtered per-user
        if (StorageUtil.uid != null) {
          await IndexedDBHelper.saveAllForUser(
            StorageUtil.uid!,
            _filterForCache(_notifications),
          );
        }
        notifyListeners();
      }
    } catch (e) {
      print("❌ Fetch notifications error: $e");
    }
  }

  /// Clear all notifications (memory + cache)
  Future<void> clearNotifications() async {
    _notifications = [];
    notifyListeners();

    if (StorageUtil.uid != null) {
      IndexedDBHelper.clearForUser(StorageUtil.uid!);
    }
  }
}
