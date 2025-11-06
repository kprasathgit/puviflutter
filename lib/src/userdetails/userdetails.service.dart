import 'package:puvi/src/common/apiservice.dart';
import 'package:puvi/src/common/constantvalues.dart';
import 'package:puvi/src/common/customexception.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/src/models/user.dart';

class UserDetailsService {
  Future<User?> registerUser(Map<String, String> userDetails) async {
    try {
      final result = await ApiService.post<User>(
        url: Urls.authRegister,
        body: userDetails,
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
      print("Error in Registeruser: $e");
      return null;
    }
  }

  Future<User?> updateUserProfile(Map<String, String> updateData) async {
    try {
      final result = await ApiService.post<User>(
        url: Urls.updateUser,
        body: updateData,
        fromJson: (data) => User.fromMap(data),
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
      print("Error in Registeruser: $e");
      return null;
    }
  }
}
