import 'package:flutter/material.dart';
import 'package:puvi/src/homepage/homepage.service.dart';
import 'package:puvi/src/models/product.dart';
import 'package:collection/collection.dart';

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

  /// Gets product by ID either from cache or by fetching from API
  Future<Product?> getProductByIdOrFetch(String proCode) async {
    // Try from cache
    Product? cached = listProduct.firstWhereOrNull((p) => p.procode == proCode);
    if (cached != null) return cached;

    // Not in memory, fetch from backend
    try {
      final product = await homescreenService.fetchProductById(proCode);
      if (product != null) {
        listProduct.add(product);
        notifyListeners();
      }
      return product;
    } catch (e) {
      print("❌ Failed to fetch product by ID: $e");
      return null;
    }
  }

  /// Gets product by slug (used in ProductDetailsScreen)
  Future<Product?> getProductBySlug(String slug) async {
    Product? cached = listProduct.firstWhereOrNull((p) => p.slug == slug);
    if (cached != null) return cached;

    try {
      if (listProduct.isEmpty) {
        await fetchProducts(forceRefresh: true);
      }
      final product = await homescreenService.fetchProductBySlug(slug);
      if (product != null) {
        listProduct.add(product);
        notifyListeners();
      }
      return product;
    } catch (e) {
      print("❌ Failed to fetch product by Slug: $e");
      return null;
    }
  }
}
