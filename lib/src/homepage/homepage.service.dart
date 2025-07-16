import 'dart:convert';

import 'package:puvi/src/common/urls.dart';
import 'package:puvi/src/models/product.dart';
import 'package:http/http.dart' as http;

class HomescreenService {
  var headers = {'Content-Type': 'application/json'};

  Future<List<Product>> fetchProducts() async {
    try {
      var request = http.Request("GET", Uri.parse(Urls.fetchProducts));
      request.headers.addAll(headers);

      http.StreamedResponse streamedResponse = await request.send();
      if (streamedResponse.statusCode != 200) {
        //var errbody = json.decode(await streamedResponse.stream.bytesToString())
        //    as Map<String, dynamic>;
        // print(errbody);
        //  throw Exception(errbody.toString());
        throw Exception("Something went wrong!");
      }
      var data =
          json.decode(await streamedResponse.stream.bytesToString()) as List;
      final list = data.map((e) => Product.fromMap(e)).toList(); // ✅ FIXED
      //  print(list);
      return list;
    } catch (e) {
      throw Exception("Something went wrong!");
      // throw Exception(e.toString());
    }
  }
}
