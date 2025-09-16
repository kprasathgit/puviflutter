import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:puvi/main.dart';
import 'package:puvi/src/models/user.dart';
import 'package:puvi/src/utility/indexeddbhelper.dart';
import 'package:universal_html/html.dart' as html;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:convert/convert.dart';
import 'dart:math';

class CryptoHelper {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows!');

  /// Encrypts text with random IV. Returns base64 in format: iv:ciphertext
  static String encryptText(String plainText) {
    try {
      final iv = encrypt.IV.fromLength(16); // zero IV fallback
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      // Store IV + ciphertext in base64
      final combined = iv.bytes + encrypted.bytes;
      return base64Encode(combined);
    } catch (_) {
      return plainText;
    }
  }

  /// Decrypts base64 string in format iv+ciphertext
  static String decryptText(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final bytes = base64Decode(encryptedText);
      if (bytes.length < 16) return encryptedText; // too short, fallback

      final ivBytes = bytes.sublist(0, 16);
      final cipherBytes = bytes.sublist(16);
      final iv = encrypt.IV(ivBytes);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypt.Encrypted(Uint8List.fromList(cipherBytes));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print("Decrypt failed: $e");
      return encryptedText; // fallback to old/deprecated
    }
  }
}

class StorageUtil {
  static final ValueNotifier<String?> uidNotifier =
      ValueNotifier<String?>(_safeDecrypt(html.window.localStorage['uid']));
  static final ValueNotifier<String?> mobileNotifier =
      ValueNotifier<String?>(_safeDecrypt(html.window.localStorage['mobile']));

  static String? _safeDecrypt(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return CryptoHelper.decryptText(value);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUserLocally(User user) async {
    if (user.uid == null || user.username == null) {
      throw Exception("Cannot save user: missing UID or username");
    }

    // Remove sensitive data
    user.password = null;
    user.jwttoken = null;
    user.refreshtoken = null;

    // Encrypt and store
    html.window.localStorage['user'] =
        CryptoHelper.encryptText(jsonEncode(user.toMap()));
    html.window.localStorage['uid'] = CryptoHelper.encryptText(user.uid!);
    html.window.localStorage['mobile'] =
        CryptoHelper.encryptText(user.mobileno!);

    uidNotifier.value = user.uid!;
    mobileNotifier.value = user.mobileno!;
  }

  static String? get uid => _safeDecrypt(html.window.localStorage['uid']);
  static String? get mobile => _safeDecrypt(html.window.localStorage['mobile']);

  static Future<User?> getUserLocally() async {
    final encryptedUser = html.window.localStorage['user'];
    if (encryptedUser == null) return null;

    try {
      final decryptedJson = CryptoHelper.decryptText(encryptedUser);
      return User.fromMap(jsonDecode(decryptedJson));
    } catch (e) {
      print("Decryption/Parsing failed: $e");
      // Clear broken user storage to avoid future failures
      await clear();
      return null;
    }
  }

  static Future<void> clear() async {
    html.window.localStorage.remove('user');
    html.window.localStorage.remove('uid');
    html.window.localStorage.remove('mobile');
    html.window.localStorage.clear();

    await notificationController.clearNotifications();
    IndexedDBHelper.clearAll();

    uidNotifier.value = null;
    mobileNotifier.value = null;
  }
}
