import 'dart:async';
import 'package:flutter/material.dart';
import 'package:puvi/src/cart/cartservice.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, [this.qty = 1]);
  double get total => product.price * qty;
}

class CartController extends ChangeNotifier {
  final CartService cartService = CartService();
  List<CartItem> items = [];
  bool _isProcessing = false;
  bool? isMobileVerified;
  StreamSubscription<List<CartItem>>? _cartSubscription;

  String? get uid => StorageUtil.uid;

  CartController() {
    // 🔹 Listen to UID changes reactively
    StorageUtil.uidNotifier.addListener(_onUidChanged);
    if (uid != null) _init();
  }

  void _onUidChanged() {
    _cartSubscription?.cancel();
    items.clear();
    notifyListeners();

    if (uid != null) {
      _init();
    } else {
      isMobileVerified = null;
    }
  }

  Future<void> _init() async {
    if (uid == null) return;
    isMobileVerified = await cartService.isUserMobileVerified(uid!);
    _startListening();
  }

  void _startListening() {
    if (uid == null) return;
    _cartSubscription?.cancel();
    _cartSubscription = cartService.getCartItems(uid!).listen((cartItems) {
      items = cartItems;
      notifyListeners();
    });
  }

  Future<void> add(Product product, int qty) async {
    // if (uid == null || _isProcessing) return;
    // if (isMobileVerified != true) throw Exception("User's mobile not verified");

    if (_isProcessing) return;
    _isProcessing = true;

    final index =
        items.indexWhere((item) => item.product.procode == product.procode);
    if (index >= 0) {
      items[index].qty += qty;
    } else {
      items.add(CartItem(product, qty));
    }
    notifyListeners();
    if (uid == null) return;
    try {
      cartService.addToCart(uid!, product, qty);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> remove(Product product) async {
    // if (uid == null || _isProcessing) return;
    // if (isMobileVerified != true) throw Exception("User's mobile not verified");

    if (_isProcessing) return;
    _isProcessing = true;

    _isProcessing = true;
    items.removeWhere((item) => item.product.procode == product.procode);
    notifyListeners();
    if (uid == null) return;
    try {
      await cartService.removeFromCart(uid!, product.procode);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> clear() async {
    // if (uid == null || _isProcessing) return;
    // if (isMobileVerified != true) throw Exception("User's mobile not verified");

    if (_isProcessing) return;
    _isProcessing = true;

    final copyItems = List<CartItem>.from(items);
    items.clear();
    notifyListeners();
    if (uid == null) return;
    for (final item in copyItems) {
      await remove(item.product);
    }
  }

  double get subTotal => items.fold(0, (sum, item) => sum + item.total);

  @override
  void dispose() {
    _cartSubscription?.cancel();
    StorageUtil.uidNotifier.removeListener(_onUidChanged);
    super.dispose();
  }
}
