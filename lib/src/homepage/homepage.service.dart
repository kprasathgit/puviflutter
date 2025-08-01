import 'package:puvi/src/common/apiservice.dart';
import 'package:puvi/src/common/constantvalues.dart';
import 'package:puvi/src/common/customexception.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/src/models/product.dart';

class HomescreenService {
  /// 🔹 Fetch list of all products
  Future<List<Product>> fetchProducts() async {
    try {
      final result = await ApiService.get<List<Product>>(
        url: Urls.fetchProducts,
        fromJson: (json) =>
            (json as List).map((e) => Product.fromMap(e)).toList(),
      );
      return result.status ? result.returnObject ?? [] : [];
    } catch (e) {
      print("Error in fetchProducts: $e");
      return [];
    }
  }

  /// 🔹 Fetch single product by procode
  Future<Product?> fetchProductById(String procode) async {
    try {
      final result = await ApiService.get<Product>(
        url: Urls.fetchProductById,
        queryParams: {'procode': procode},
        fromJson: (json) => Product.fromMap(json),
      );
      return result.status ? result.returnObject : null;
    } catch (e) {
      print("Error in fetchProductById: $e");
      return null;
    }
  }

  /// 🔹 Fetch product by slug
  Future<Product?> fetchProductBySlug(String slug) async {
    try {
      final result = await ApiService.get<Product>(
        url: '${Urls.slug}/$slug',
        fromJson: (json) => Product.fromMap(json),
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
      print("Error in fetchProductBySlug: $e");
      return null;
    }
  }

  /// 🔹 Save or update product
  Future<Product?> saveProduct(Product product) async {
    try {
      final result = await ApiService.post<Product>(
        url: Urls.saveProduct,
        body: product.toMap(),
        fromJson: (json) => Product.fromMap(json),
      );
      return result.status ? result.returnObject : null;
    } catch (e) {
      print("Error in saveProduct: $e");
      return null;
    }
  }

  /// 🔹 Call an API that returns a simple string
  Future<String?> getWelcomeMessage() async {
    try {
      final result = await ApiService.get<String>(
        url: '${Urls.productMappingUrl}/welcome',
        fromJson: (json) => json.toString(),
      );
      return result.status ? result.returnObject : null;
    } catch (e) {
      print("Error in getWelcomeMessage: $e");
      return null;
    }
  }

  /// 🔹 Call an API that returns only boolean status
  Future<bool> toggleProductAvailability(String procode) async {
    try {
      final result = await ApiService.post<bool>(
        url: '${Urls.productMappingUrl}/toggleavailability',
        body: {'procode': procode},
        fromJson: (json) => json as bool,
      );
      return result.status && result.returnObject == true;
    } catch (e) {
      print("Error in toggleProductAvailability: $e");
      return false;
    }
  }

  /// 🔹 Delete product by procode (return only status)
  Future<bool> deleteProduct(String procode) async {
    try {
      final result = await ApiService.post<bool>(
        url: '${Urls.productMappingUrl}/delete',
        body: {'procode': procode},
        fromJson: (json) => json as bool,
      );
      return result.status;
    } catch (e) {
      print("Error in deleteProduct: $e");
      return false;
    }
  }
}
