import 'package:flutter/material.dart';
import 'package:puvi/src/models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, [this.qty = 1]);
  double get total => product.price * qty;
}

class CartController extends ChangeNotifier {
  // static final instance = CartController._();
  // CartController._();
  final items = <CartItem>[];
  void add(Product product, int qty) {
    final idx = items.indexWhere((i) => i.product.procode == product.procode);
    if (idx >= 0) {
      items[idx].qty += qty;
    } else {
      items.add(CartItem(product, qty));
    }
    notifyListeners();
  }

  void remove(Product product) {
    items.removeWhere((i) => i.product.procode == product.procode);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }

  double get subTotal => items.fold(0, (sum, i) => sum + i.total);
}
