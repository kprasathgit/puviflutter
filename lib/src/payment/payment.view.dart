  import 'dart:convert';
  import 'dart:developer';

  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:fluttertoast/fluttertoast.dart';
  import 'package:http/http.dart' as http;
  import 'package:razorpay_web/razorpay_web.dart';
  import 'package:puvi/src/common/urls.dart';
  import 'package:go_router/go_router.dart';

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
      _razorpay.on(RazorpayEvents.EVENT_PAYMENT_SUCCESS, handleSuccess);
      _razorpay.on(RazorpayEvents.EVENT_PAYMENT_ERROR, handleFailure);
      _razorpay.on(RazorpayEvents.EVENT_EXTERNAL_WALLET, handleWallet);
      fetchOrderData();
    }

    @override
    void dispose() {
      _razorpay.clear();
      super.dispose();
    }

    Future<void> fetchOrderData() async {
      final url = Uri.parse('${Urls.fetchOrder}/${widget.secureKey}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          orderData = jsonDecode(response.body);
          loading = false;
        });
      } else {
        Fluttertoast.showToast(msg: "Order not found or expired");
        context.go('/error');
      }
    }

    void _openCheckout() {
      if (orderData == null) return;

      var options = {
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
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        Fluttertoast.showToast(msg: "Failed to open Razorpay: $e");
      }
    }

    void handleSuccess(PaymentSuccessResponse res) {
      log("✅ Payment Success: ${res.paymentId}");
      Fluttertoast.showToast(msg: "Success: ${res.paymentId}");
      // context.go('/success');
        // Navigate to order list screen
  context.go('/orders');
    }

    void handleFailure(PaymentFailureResponse res) {
      log("❌ Payment Failed: ${res.code} - ${res.message}");
      Fluttertoast.showToast(
          msg: "Error: ${res.message}",
          backgroundColor: const Color(0xFFF44336),
          webBgColor: "linear-gradient(to right, #F44336, #D32F2F)");
    }

    void handleWallet(ExternalWalletResponse res) {
      Fluttertoast.showToast(msg: "External Wallet: ${res.walletName}");
    }

    Widget upiTile(String upi, bool success) {
      return ListTile(
        tileColor: success ? Colors.green.shade50 : Colors.red.shade50,
        title: Text(upi),
        subtitle: Text(
          'UPI for ${success ? 'success' : 'failure'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copy and pay',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: upi));
            Fluttertoast.showToast(msg: "UPI copied");
            Future.delayed(const Duration(seconds: 1), _openCheckout);
          },
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      if (loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Pay Now')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              upiTile('success@razorpay', true),
              upiTile('failure@razorpay', false),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openCheckout,
                child: const Text('Buy Now'),
              )
            ],
          ),
        ),
      );
    }
  }
