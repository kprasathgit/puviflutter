import 'package:flutter/widgets.dart';
import 'package:puvi/src/forgetpassword/forgetpassword.service.dart';
import 'package:puvi/src/models/user.dart';

class ForgetpasswordController with ChangeNotifier {
  final ForgetPasswordService forgetPasswordService;
  ForgetpasswordController(this.forgetPasswordService);

  Future<bool> checkUserExists(String mobile) async {
    return await forgetPasswordService.checkUserExists(mobile);
  }

  Future<User?> resetUserPassword(String mobile, String passWord) async {
    final resetData = {'username': mobile, 'password': passWord};
    return await forgetPasswordService.resetPassword(resetData);
  }
}
