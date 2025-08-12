import 'dart:convert';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:puvi/src/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:puvi/src/common/urls.dart';
import 'package:universal_html/html.dart' as html;

class StorageUtil {
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
  }
}
