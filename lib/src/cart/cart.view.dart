import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';
import 'package:puvi/src/common/smartnavigator.dart';
import 'package:puvi/src/common/storageutil.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartController cartController;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    cartController = Provider.of<CartController>(context, listen: false);
  }

  @override
  void dispose() {
    if (_scrollController != null) {
      _scrollController!.dispose();
      _scrollController = null;
    }

    super.dispose();
  }

  void _handleCheckout(BuildContext context) {
    final uid = StorageUtil.uid;
    final orderSummaryUrl = CommonMethods.buildRedirectUrl(
      AppRouteConstants.orderSummary,
      slug: null,
    );

    if (uid == null) {
      final loginUrl = CommonMethods.buildRedirectUrl(
        AppRouteConstants.login,
        next: orderSummaryUrl,
        flow: 'checkout',
        slug: null,
      );
      SmartNavigator.go(context, loginUrl);
    } else {
      SmartNavigator.go(context, orderSummaryUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cartController, value) {
        final cart = cartController.items;

        if (cart.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cart')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Looks like you haven’t added anything yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => SmartNavigator.go(
                        context, AppRouteConstants.homeScreen),
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Start Shopping'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final total = cartController.subTotal;

        return Scaffold(
          appBar: AppBar(title: const Text('Cart')),
          body: KeyboardScrollable(
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  title: Text(item.product.proname),
                  subtitle: Text('Qty: ${item.qty}'),
                  trailing: Text('₹${item.total.toStringAsFixed(2)}'),
                  leading: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => cartController.remove(item.product),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => _handleCheckout(context),
              child: Text(
                'Proceed to Checkout - ₹${total.toStringAsFixed(2)}',
              ),
            ),
          ),
        );
      },
    );
  }
}
