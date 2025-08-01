import 'package:flutter/material.dart';
import 'package:puvi/src/models/user.dart';
import 'package:puvi/src/userdetails/userdetails.service.dart';

class UserDetailsController with ChangeNotifier {
  UserDetailsController(this.userDetailsService);
  final UserDetailsService userDetailsService;
  User? user;
  Future<User?> registerUser(Map<String, String> userDetails) async {
    user = await userDetailsService.registerUser(userDetails);
    notifyListeners();
    return user;
  }
}
