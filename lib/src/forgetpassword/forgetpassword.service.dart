import 'package:puvi/src/common/apiservice.dart';
import 'package:puvi/src/common/constantvalues.dart';
import 'package:puvi/src/common/customexception.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/src/models/user.dart';

class ForgetPasswordService {
  Future<bool> checkUserExists(String mobile) async {
    try {
      final result = await ApiService.get<User>(
        url: Urls.checkUser,
        fromJson: (json) => User.fromMap(json),
        queryParams: {'username': mobile},
      );
      return result.status == true;
    } catch (e) {
      print("Error in checking user: $e");
      return false;
    }
  }

  Future<User?> resetPassword(Map<String, Object> data) async {
    try {
      final result = await ApiService.post<User>(
        url: Urls.resetPassword,
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
      print("Password Reset Failed!");
    } catch (e) {
      print(e);
    }
    return null;
  }
}
