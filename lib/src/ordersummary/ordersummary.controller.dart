import 'package:flutter/foundation.dart';
import 'package:puvi/src/homepage/homepage.service.dart';
import 'package:puvi/src/models/product.dart';
import 'package:puvi/src/ordersummary/ordersummary.service.dart';

class OrderSummaryController with ChangeNotifier {
  final OrderSummaryService orderSummaryService;
  final HomescreenService homescreenService;
  OrderSummaryController(this.orderSummaryService, this.homescreenService);

  Future<Product?> fetchSingleProduct(String slug) async {
    return homescreenService.fetchProductBySlug(slug);
  }

  Future<String?> createOrder(Map<String, dynamic> payload) async {
    return orderSummaryService.createOrder(payload);
  }
}
