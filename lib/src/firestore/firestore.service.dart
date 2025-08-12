import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:puvi/src/common/urls.dart';

class FirestoreService {
  static const _headers = {'Content-Type': 'application/json'};

  Future<String?> fetchCustomTokenFromBackend(String uid) async {
    try {
      final url = Uri.parse('${Urls.getFirebaseToken}?uid=$uid');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['token'] as String?;
      } else {
        print("Backend error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
