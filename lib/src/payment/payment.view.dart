import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:puvi/src/common/keyboardscrollable.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:razorpay_web/razorpay_web.dart';

class PaymentScreen extends StatefulWidget {
  final String secureKey;
  const PaymentScreen({super.key, required this.secureKey});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  Map<String, dynamic>? orderData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(RazorpayEvents.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(RazorpayEvents.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(RazorpayEvents.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _fetchOrderData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchOrderData() async {
    final url = Uri.parse('${Urls.fetchOrder}/${widget.secureKey}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          orderData = jsonDecode(response.body);
          loading = false;
        });
      } else {
        _showError("Order not found or expired");
      }
    } catch (e) {
      _showError("Unable to fetch order");
    }
  }

  void _openCheckout() {
    if (orderData == null) return;

    final options = {
      'key': 'rzp_test_pF5x3pp39sVSZs',
      'amount': orderData!['amount'] * 100,
      'order_id': orderData!['razorpayOrderId'],
      'name': orderData!['name'],
      'description': 'Puvipure Order',
      'prefill': {
        'contact': orderData!['mobileno'],
        'email': 'example@test.com',
      },
      'theme': {'color': '#00b894'},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      log("Checkout failed: $e");
      Fluttertoast.showToast(msg: "Unable to start payment.");
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    log("✅ Payment ID: ${response.paymentId}");
    Fluttertoast.showToast(msg: "Payment successful!");
    context.go('/orders');
  }

  void _onPaymentError(PaymentFailureResponse response) {
    log("❌ Payment failed: ${response.code} | ${response.message}");
    Fluttertoast.showToast(
      msg: "Payment failed. Please try again.",
      backgroundColor: const Color(0xFFF44336),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  void _showError(String message) {
    Fluttertoast.showToast(msg: message);
    context.go('/error');
  }

  Widget _copyRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: "Copy $label",
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            Fluttertoast.showToast(msg: "$label copied");
          },
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    if (orderData == null) return const SizedBox();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (orderData!['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(orderData!['imageUrl'], height: 180, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text("Hi ${orderData!['name']}", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _infoTile("Order ID", orderData!['razorpayOrderId'], copyable: true),
            _infoTile("Mobile", orderData!['mobileno']),
            _infoTile("Amount", "₹${orderData!['amount']}"),
            if (orderData!.containsKey('upiId'))
              _infoTile("UPI ID", orderData!['upiId'], copyable: true),
            if (orderData!.containsKey('createdAt'))
              _infoTile("Created On", orderData!['createdAt']),
            if (orderData!.containsKey('status'))
              _infoTile("Status", orderData!['status'].toString().toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text("$title:", style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: copyable ? _copyRow(title, value) : Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Payment')),
      body: KeyboardScrollable(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildOrderDetails(),
              ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromARGB(255, 40, 143, 45),
                  foregroundColor: Colors.black
                ),
                onPressed: _openCheckout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
