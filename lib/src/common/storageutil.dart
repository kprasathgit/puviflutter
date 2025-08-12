import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:puvi/src/models/user.dart';
import 'package:universal_html/html.dart' as html;

class StorageUtil {
  // 🔹 Reactive UID and mobile using ValueNotifier
  static final ValueNotifier<String?> uidNotifier =
      ValueNotifier<String?>(html.window.localStorage['uid']);
  static final ValueNotifier<String?> mobileNotifier =
      ValueNotifier<String?>(html.window.localStorage['mobile']);

  /// Save user data locally and update notifiers
  static Future<void> saveUserLocally(User user) async {
    if (user.uid == null || user.username == null) {
      throw Exception("Cannot proceed! Missing UID or username.");
    }
    // Remove sensitive data before saving
    user.password = null;
    user.jwttoken = null;
    user.refreshtoken = null;

    html.window.localStorage['user'] = jsonEncode(user.toMap());
    html.window.localStorage['uid'] = user.uid!;
    html.window.localStorage['mobile'] = user.mobileno!;

    // 🔹 Update reactive values
    uidNotifier.value = user.uid!;
    mobileNotifier.value = user.mobileno!;
  }

  static String? get uid => uidNotifier.value;
  static String? get mobile => mobileNotifier.value;

  static Future<User?> getUserLocally() async {
    final userStr = html.window.localStorage['user'];
    if (userStr == null) return null;
    try {
      final map = jsonDecode(userStr);
      return User.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  /// Clear all local data
  static void clear() {
    html.window.localStorage.clear();
    uidNotifier.value = null;
    mobileNotifier.value = null;
  }
}
