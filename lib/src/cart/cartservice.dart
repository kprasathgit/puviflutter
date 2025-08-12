import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/models/product.dart';

class CartService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> isUserMobileVerified(String uid) async {
    final userDoc = await firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return false;
    final userDetails = userDoc.data()?['userDetails'];
    return userDetails != null && userDetails['ismobilenoverified'] == true;
  }

  Future<void> addToCart(String uid, Product product, int qty) async {
    // if (!await isUserMobileVerified(uid)) {
    //   throw Exception("User's mobile not verified");
    // }
    final cartItemRef = firestore
        .collection('carts')
        .doc(uid)
        .collection('items')
        .doc(product.procode);

    final doc = await cartItemRef.get();
    if (doc.exists) {
      final currentQty = doc.data()?['qty'] ?? 0;
      await cartItemRef.update({'qty': currentQty + qty});
    } else {
      await cartItemRef.set({
        'product': product.toMap(), // save full product map here
        'qty': qty,
      });
    }
  }

  Future<void> removeFromCart(String uid, String productCode) async {
    final cartItemRef = firestore
        .collection('carts')
        .doc(uid)
        .collection('items')
        .doc(productCode);
    await cartItemRef.delete();
  }

  Stream<List<CartItem>> getCartItems(String uid) {
    return firestore
        .collection('carts')
        .doc(uid)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final productMap = Map<String, dynamic>.from(data['product']);
              final product = Product.fromMap(productMap);
              return CartItem(
                product,
                data['qty'] ?? 1,
              );
            }).toList());
  }
}
