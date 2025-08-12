// storageutil.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:puvi/src/models/user.dart';
import 'package:universal_html/html.dart' as html;

class StorageUtil extends ChangeNotifier {
  static final StorageUtil _instance = StorageUtil._internal();
  factory StorageUtil() => _instance;
  StorageUtil._internal();

  static Future<void> saveUserLocally(User user) async {
    if (user.uid == null || user.username == null) {
      throw Exception("Cannot proceed.! User is missing uid or username.");
    }
    user.password = null;
    user.jwttoken = null;
    user.refreshtoken = null;

    html.window.localStorage['user'] = jsonEncode(user.toMap());
    html.window.localStorage['uid'] = user.uid!;
    html.window.localStorage['mobile'] = user.mobileno!;

    _instance.notifyListeners(); // 👈 Notify changes
  }

  static String? get uid => html.window.localStorage['uid'];
  static String? get username => html.window.localStorage['mobile'];

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

  static void clear() {
    html.window.localStorage.clear();
    _instance.notifyListeners(); // 👈 Notify when cleared
  }

  // To allow listening
  static StorageUtil get notifier => _instance;
}
