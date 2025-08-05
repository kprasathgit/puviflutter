import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/models/product.dart';
import 'package:puvi/src/models/user.dart';

class CommonMethods {
  static String buildRedirectUrl(
    String basePath, {
    String? next,
    String? flow,
    String? slug,
  }) {
    final params = <String, String>{};
    if (next != null && next.isNotEmpty) params['next'] = next;
    if (flow != null && flow.isNotEmpty) params['flow'] = flow;
    if (slug != null && slug.isNotEmpty) params['slug'] = slug;

    if (params.isEmpty) return basePath;

    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$basePath?$queryString';
  }

  static Map<String, dynamic> fromSingleProduct({
    required String uid,
    required User user,
    required Product product,
    required int qty,
    required double amount,
  }) {
    return {
      'uid': uid,
      'userName': user.username,
      'name': user.name,
      'phone': user.mobileno,
      'shippingAddress': user.address,
      'amount': amount,
      'listProCode': [product.procode],
      'qtyList': [qty],
      'priceList': [product.price],
    };
  }

  static Map<String, dynamic> fromCart({
    required String uid,
    required User user,
    required List<CartItem> cartItems,
  }) {
    return {
      'uid': uid,
      'userName': user.username,
      'name': user.name,
      'phone': user.mobileno,
      'shippingAddress': user.address,
      'amount': cartItems.fold(0.0, (sum, item) => sum + item.total),
      'listProCode': cartItems.map((e) => e.product.procode).toList(),
      'qtyList': cartItems.map((e) => e.qty).toList(),
      'priceList': cartItems.map((e) => e.product.price).toList(),
    };
  }
}
