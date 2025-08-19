import 'package:flutter/foundation.dart';
import 'package:puvi/src/login/login.service.dart';
import 'package:puvi/src/models/user.dart';

class LoginController with ChangeNotifier {
  final LoginService loginService;

  LoginController(this.loginService);

  Future<User?> checkLogin(Map<String, String> data) async {
    return await loginService.checkLogin(data);
  }

  Future<User?> updateFcmToken(String uid, String fcmToken) async {
    return await loginService.updateFcmToken(uid, fcmToken);
  }
}
