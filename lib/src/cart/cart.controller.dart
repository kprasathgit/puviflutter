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
  String? get uid => StorageUtil.uid;

  // Flag to prevent concurrent add/remove ops (optional)
  bool _isProcessing = false;
  bool? isMobileVerified;

  CartController() {
    if (uid != null) {
      _init();
    }
  }
  Future<void> _init() async {
    isMobileVerified = await cartService.isUserMobileVerified(uid!);
    _startListening();
    notifyListeners(); // to reflect any UI changes if needed
  }

  void _startListening() {
    cartService.getCartItems(uid!).listen((cartItems) {
      items = cartItems;
      notifyListeners();
    });
  }

  // Optimistic add to cart
  Future<void> add(Product product, int qty) async {
    if (uid == null || _isProcessing) return;

    if (isMobileVerified != true) {
      throw Exception("User's mobile not verified");
    }
    _isProcessing = true;

    // Find existing item locally
    final index =
        items.indexWhere((item) => item.product.procode == product.procode);

    if (index >= 0) {
      // Update qty locally
      items[index].qty += qty;
    } else {
      // Add new item locally
      items.add(CartItem(product, qty));
    }
    notifyListeners();

    try {
      // Update Firestore
      cartService.addToCart(uid!, product, qty);
      print("added");
    } catch (e) {
      // On error, revert optimistic update by reloading from Firestore stream
      // You could also choose to show error toast/dialog here
      // For now, do nothing and rely on Firestore stream to fix UI
    } finally {
      _isProcessing = false;
    }
  }

  // Optimistic remove from cart
  Future<void> remove(Product product) async {
    if (uid == null || _isProcessing) return;

    if (isMobileVerified != true) {
      throw Exception("User's mobile not verified");
    }
    _isProcessing = true;

    // Remove locally first
    items.removeWhere((item) => item.product.procode == product.procode);
    notifyListeners();

    try {
      await cartService.removeFromCart(uid!, product.procode);
    } catch (e) {
      // On error, you might want to reload or show error
      // For now, rely on Firestore stream sync to correct state
    } finally {
      _isProcessing = false;
    }
  }

  // Clear all cart items optimistically
  Future<void> clear() async {
    if (uid == null) return;

    if (isMobileVerified != true) {
      throw Exception("User's mobile not verified");
    }
    final copyItems = List<CartItem>.from(items);

    // Clear locally
    items.clear();
    notifyListeners();

    // Remove from Firestore one by one
    for (final item in copyItems) {
      try {
        await remove(item.product);
      } catch (e) {
        // handle errors optionally here
      }
    }
  }

  double get subTotal => items.fold(0, (sum, item) => sum + item.total);
}
