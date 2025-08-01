import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/models/product.dart';
import 'package:puvi/src/ordersummary/ordersummary.controller.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String? slug; // Null means cart flow

  const OrderSummaryScreen({super.key, this.slug});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool isLoading = true;
  bool isCreatingOrder = false;
  String? error;
  Product? singleProduct;
  late OrderSummaryController orderSummaryController;

  @override
  void initState() {
    super.initState();
    orderSummaryController =
        Provider.of<OrderSummaryController>(context, listen: false);
    if (widget.slug != null) {
      fetchSingleProduct(widget.slug!);
    } else {
      isLoading = false;
    }
  }

  Future<void> fetchSingleProduct(String slug) async {
    try {
      final product = await orderSummaryController.fetchSingleProduct(slug);
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Product details not Found")),
        );
        return;
      }
      setState(() {
        singleProduct = product;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = '⚠️ Error fetching product: $e';
        isLoading = false;
      });
    }
  }

  Future<void> createOrder() async {
    if (isCreatingOrder) return;
    setState(() => isCreatingOrder = true);

    final uid = StorageUtil.uid;
    final user = await StorageUtil.getUserLocally();

    if (uid == null || user == null) {
      final nextUrl = CommonMethods.buildRedirectUrl(
        AppRouteConstants.orderSummary,
        slug: widget.slug,
      );
      final redirectTo = CommonMethods.buildRedirectUrl(
        AppRouteConstants.login,
        flow: 'checkout',
        slug: widget.slug,
        next: nextUrl,
      );
      context.go(redirectTo);
      setState(() => isCreatingOrder = false);
      return;
    }

    if (widget.slug != null && singleProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Product details not available")),
      );
      setState(() => isCreatingOrder = false);
      return;
    }

    final payload = widget.slug == null
        ? CommonMethods.fromCart(
            uid: uid,
            user: user,
            cartItems: context.read<CartController>().items,
          )
        : CommonMethods.fromSingleProduct(
            uid: uid,
            user: user,
            product: singleProduct!,
          );

    try {
      final res = await http.post(
        Uri.parse(Urls.createOrder),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        final secureKey = jsonDecode(res.body)['secureKey'];
        context.go('${AppRouteConstants.payment}/$secureKey');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Order creation failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ $e")),
      );
    } finally {
      if (mounted) setState(() => isCreatingOrder = false);
    }
  }

  Widget _buildItemTile(String name, int qty, double total, {String? imageUrl}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null
            ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 50),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text("Qty: $qty"),
      trailing: Text("₹${total.toStringAsFixed(2)}"),
    );
  }

  Widget _buildProductList() {
    final isCart = widget.slug == null;
    final cartItems = context.watch<CartController>().items;

    if (isCart) {
      return Column(
        children: cartItems
            .map((item) => _buildItemTile(
                  item.product.proname,
                  item.qty,
                  item.total,
                  imageUrl: item.product.imageurl,
                ))
            .toList(),
      );
    } else {
      return _buildItemTile(
        singleProduct?.proname ?? "--",
        1,
        singleProduct?.price?.toDouble() ?? 0,
        imageUrl: singleProduct?.imageurl,
      );
    }
  }

  double _calculateTotal() {
    if (widget.slug == null) {
      final cartItems = context.read<CartController>().items;
      return cartItems.fold(0.0, (sum, item) => sum + item.total);
    } else {
      return singleProduct?.price?.toDouble() ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCart = widget.slug == null;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Order Summary")),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Order Summary")),
      body: KeyboardScrollable(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCart ? "Items in Cart" : "Product Details",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildProductList(),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          Text("₹${_calculateTotal().toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isCreatingOrder
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.lock),
                  label: Text(
                    isCreatingOrder ? 'Creating Order...' : 'Proceed to Payment',
                  ),
                  onPressed: isCreatingOrder ? null : createOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color.fromARGB(255, 140, 102, 206),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
