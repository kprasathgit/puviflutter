// File: ordersummary.view.dart (or wherever you keep this)
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/common/buynowsession.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/models/product.dart';
import 'package:puvi/src/ordersummary/ordersummary.controller.dart';
import 'package:universal_html/html.dart' as html;

class OrderSummaryScreen extends StatefulWidget {
  final String? slug; // Null means cart flow

  // NEW optional named params for retry support:
  final String? retryFlow;
  final bool autoRetry;

  const OrderSummaryScreen({
    super.key,
    this.slug,
    this.retryFlow,
    this.autoRetry = false,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool isLoading = true;
  bool isCreatingOrder = false;
  String? error;
  Product? singleProduct;
  late OrderSummaryController orderSummaryController;
  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    orderSummaryController =
        Provider.of<OrderSummaryController>(context, listen: false);

    // Combine widget-provided retry info with localStorage (web) retry info.
    // final savedFlow = widget.retryFlow ??
    //     ((kIsWeb && html.window.localStorage['retryFlow'] != null)
    //         ? html.window.localStorage['retryFlow']
    //         : null);
    // final savedSlug = widget.slug ??
    //     ((kIsWeb && html.window.localStorage['retrySlug'] != null)
    //         ? html.window.localStorage['retrySlug']
    //         : null);

    final savedFlow = widget.retryFlow;
    final savedSlug = widget.slug;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool retryDone = false;

      // While loop retry logic - retry once if conditions met
      while (!retryDone && savedFlow != null && savedFlow.isNotEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text(
        //       "Last payment failed. Retry Again",
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     backgroundColor: Colors.red,
        //     duration: Duration(seconds: 2),
        //   ),
        // );

        CommonMethods.showToast("Last payment failed. Retry Again",
            toastLength: Toast.LENGTH_LONG);

        // Fetch product if needed
        if (savedSlug != null && singleProduct == null) {
          await fetchSingleProduct(savedSlug);
        }

        // Call createOrder with saved retry info
        //  await createOrder(flow: savedFlow, slug: savedSlug);

        retryDone = true; // break after one retry
        setState(() {
          isLoading = false;
        });
      }

      // If no retry needed, just proceed with normal fetch
      if (!retryDone) {
        if (widget.slug != null) {
          if (BuyNowSession.isAvailable) {
            setState(() {
              singleProduct = BuyNowSession.product;
              isLoading = false;
            });
          } else {
            await fetchSingleProduct(widget.slug!);
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    });
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

  Future<void> createOrder({String? flow, String? slug}) async {
    if (isCreatingOrder) return;
    setState(() => isCreatingOrder = true);

    final uid = StorageUtil.uid;
    final user = await StorageUtil.getUserLocally();

    if (uid == null || user == null) {
      // PRESERVE retry flags across login redirect (important enhancement)
      if (kIsWeb && flow != null) {
        html.window.localStorage['retryFlow'] = flow;
        if (slug != null && slug.isNotEmpty) {
          html.window.localStorage['retrySlug'] = slug;
        }
      }

      final nextUrl = CommonMethods.buildRedirectUrl(
        AppRouteConstants.orderSummary,
        slug: slug ?? widget.slug,
      );
      final redirectTo = CommonMethods.buildRedirectUrl(
        AppRouteConstants.login,
        flow: flow ?? (widget.slug != null ? 'buyNow' : 'cart'),
        slug: slug ?? widget.slug,
        next: nextUrl,
      );
      context.go(redirectTo);
      setState(() => isCreatingOrder = false);
      return;
    }

    if ((slug ?? widget.slug) != null && singleProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Product details not available")),
      );
      setState(() => isCreatingOrder = false);
      return;
    }

    final payload = (slug ?? widget.slug) == null
        ? CommonMethods.fromCart(
            uid: uid,
            user: user,
            cartItems: context.read<CartController>().items,
          )
        : CommonMethods.fromSingleProduct(
            uid: uid,
            user: user,
            product: singleProduct!,
            qty: BuyNowSession.qty,
            amount: (singleProduct?.price ?? 0) * BuyNowSession.qty,
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
// debugPrint('Response status: ${res.statusCode}');
// debugPrint('Response body: ${res.body}');
      if (res.statusCode == 200) {
        final secureKey = jsonDecode(res.body)['secureKey'];

        // Store flow + slug for retry in case payment fails
        if (kIsWeb) {
          html.window.localStorage['retryFlow'] =
              flow ?? (widget.slug != null ? 'buyNow' : 'cart');
          html.window.localStorage['retrySlug'] = slug ?? widget.slug ?? '';
        }

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

  Widget _buildItemTile(String name, int qty, double total,
      {String? imageUrl}) {
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
        BuyNowSession.qty,
        (singleProduct?.price ?? 0) * BuyNowSession.qty,
        imageUrl: singleProduct?.imageurl,
      );
    }
  }

  double _calculateTotal() {
    if (widget.slug == null) {
      final cartItems = context.read<CartController>().items;
      return cartItems.fold(0.0, (sum, item) => sum + item.total);
    } else {
      return (singleProduct?.price ?? 0) * BuyNowSession.qty;
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
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: _scrollController,
            // shrinkWrap: true, // So ListView wraps content height if small
            //physics: const ClampingScrollPhysics(), // Better for nested scroll
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCart ? "Items in Cart" : "Product Details",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildProductList(),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "₹${_calculateTotal().toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // add more widgets here if needed
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
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
            onPressed: isCreatingOrder
                ? null
                : () => createOrder(
                      flow: widget.slug != null ? 'buyNow' : 'cart',
                      slug: widget.slug,
                    ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color.fromARGB(255, 140, 102, 206),
              foregroundColor: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
