import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:puvi/main.dart';
import 'package:puvi/src/models/user.dart';
import 'package:puvi/src/utility/indexeddbhelper.dart';
import 'package:universal_html/html.dart' as html;

class StorageUtil {
  static final ValueNotifier<String?> uidNotifier =
      ValueNotifier<String?>(html.window.localStorage['uid']);
  static final ValueNotifier<String?> mobileNotifier =
      ValueNotifier<String?>(html.window.localStorage['mobile']);

  static Future<void> saveUserLocally(User user) async {
    if (user.uid == null || user.username == null) {
      throw Exception("Cannot save user: missing UID or username");
    }

    // Remove sensitive data
    user.password = null;
    user.jwttoken = null;
    user.refreshtoken = null;

    html.window.localStorage['user'] = jsonEncode(user.toMap());
    html.window.localStorage['uid'] = user.uid!;
    html.window.localStorage['mobile'] = user.mobileno!;

    uidNotifier.value = user.uid!;
    mobileNotifier.value = user.mobileno!;
  }

  static String? get uid => uidNotifier.value;
  static String? get mobile => mobileNotifier.value;

  static Future<User?> getUserLocally() async {
    final userStr = html.window.localStorage['user'];
    if (userStr == null) return null;
    try {
      return User.fromMap(jsonDecode(userStr));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    // Clear localStorage
    html.window.localStorage.remove('user');
    html.window.localStorage.remove('uid');
    html.window.localStorage.remove('mobile');
    html.window.localStorage.clear();
    await notificationController.clearNotifications();
    IndexedDBHelper.clearAll();
    uidNotifier.value = null;
    mobileNotifier.value = null;
  }
}
