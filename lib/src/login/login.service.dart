import 'package:puvi/src/common/apiservice.dart';
import 'package:puvi/src/common/constantvalues.dart' show ConstantValues;
import 'package:puvi/src/common/customexception.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/src/models/user.dart';

class LoginService {
  Future<User?> checkLogin(Map<String, String> data) async {
    try {
      final result = await ApiService.post(
        url: Urls.authLogin,
        body: data,
        fromJson: (json) => User.fromMap(json),
      );
      return result.status
          ? result.returnObject
          : !result.status
              ? throw CustomException(
                  result.message ?? ConstantValues.commonErrorMsg)
              : null;
    } on CustomException {
      rethrow;
    } catch (e) {
      print("Error in checkLogin: $e");
      return null;
    }
  }

  Future<User?> updateFcmToken(String uid, String fcmToken) async {
    try {
      final body = {'uid': uid, 'fcmtoken': fcmToken};

      final result = await ApiService.post<User>(
        url: Urls.updateFcmToken,
        body: body,
        fromJson: (json) => User.fromMap(json),
      );
      return result.status
          ? result.returnObject
          : !result.status
              ? throw CustomException(
                  result.message ?? ConstantValues.commonErrorMsg)
              : null;
    } on CustomException {
      print("FCMtoken updation failed!");
    } catch (e) {
      print(e);
    }
  }
}
