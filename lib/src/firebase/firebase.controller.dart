import 'package:flutter/material.dart';
import 'package:puvi/src/firebase/firebase.service.dart';

class FirebaseController with ChangeNotifier {
  final FirebaseService firebaseService;

  FirebaseController(this.firebaseService);

  String? get fcmToken => FirebaseService.token;
}
