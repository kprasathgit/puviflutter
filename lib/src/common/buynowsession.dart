import 'package:puvi/src/models/product.dart';

class BuyNowSession {
  static Product? _product;
  static int _qty = 1;

  static void set({required Product product, required int qty}) {
    _product = product;
    _qty = qty;
  }

  static Product? get product => _product;
  static int get qty => _qty;

  static void clear() {
    _product = null;
    _qty = 1;
  }

  static bool get isAvailable => _product != null;
}
