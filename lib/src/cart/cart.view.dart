import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/common/smartnavigator.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartController cartController;

  @override
  void initState() {
    super.initState();
    cartController = Provider.of<CartController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>().items;
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
                onPressed: () =>
                    SmartNavigator.go(context, AppRouteConstants.homeScreen),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Start Shopping'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final total = context.watch<CartController>().subTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListView(
        children: cart
            .map((c) => ListTile(
                  title: Text(c.product.proname),
                  subtitle: Text('Qty: ${c.qty}'),
                  trailing: Text('₹${c.total.toStringAsFixed(2)}'),
                  leading: IconButton(
                      onPressed: () => cartController.remove(c.product),
                      icon: const Icon(Icons.delete)),
                ))
            .toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton(
            onPressed: () =>
                SmartNavigator.go(context, AppRouteConstants.userDetails),
            child: Text('Proceed to Checkout - ₹${total.toStringAsFixed(2)}')),
      ),
    );
  }
}
