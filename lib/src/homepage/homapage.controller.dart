import 'package:flutter/material.dart';
import 'package:puvi/src/homepage/homepage.service.dart';
import 'package:puvi/src/models/product.dart';

class HomescreenController with ChangeNotifier {
  HomescreenController(this.homescreenService);

  final HomescreenService homescreenService;
  final List<Product> listProduct = [];

  /// Fetch products only if not already cached or forced
  Future<List<Product>> fetchProducts(
      {String? catcode, bool forceRefresh = false}) async {
    if (listProduct.isEmpty || forceRefresh) {
      try {
        final fetched = await homescreenService.fetchProducts();
        listProduct.clear();
        listProduct.addAll(fetched);
        notifyListeners();
      } catch (e) {
        throw Exception("Unable to load products: $e");
      }
    }

    return filterByCategory(catcode);
  }

  /// Filters product list by category code
  List<Product> filterByCategory(String? catcode) {
    if (catcode == null) return List.from(listProduct);
    return listProduct
        .where((p) => p.category.categorycode == catcode)
        .toList();
  }
}
