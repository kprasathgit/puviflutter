import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:flutter/foundation.dart';
import 'package:puvi/src/firestore/firestore.service.dart';

class FirestoreController with ChangeNotifier {
  final FirestoreService firestoreService;

  FirestoreController(this.firestoreService);

  Future<void> signInFirebaseWithCustomToken(String uid) async {
    final token = await firestoreService.fetchCustomTokenFromBackend(uid);
    if (token != null) {
      try {
        await FirebaseAuthWeb.instance.signInWithCustomToken(token);
        // print("Firebase signed in as user $uid");
      } catch (e) {
        print("Firebase sign-in error: $e");
      }
    } else {
      print("Failed to get Firebase custom token");
    }
  }
}
