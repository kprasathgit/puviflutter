import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/commonmethods.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:universal_html/html.dart' as html;

class PaymentScreen extends StatefulWidget {
  final String secureKey;
  final String? slug; // Optional slug for retry flow

  const PaymentScreen({super.key, required this.secureKey, this.slug});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  Map<String, dynamic>? orderData;
  bool loading = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _sessionTimer;
  bool _sessionExpired = false;
  bool _paymentInProgress = false;
  DateTime? _paymentStartTime;
  int sessionExpiry = 5;

  void _startSessionTimer(int sessionExpiryDuration) {
    _sessionTimer = Timer(Duration(minutes: sessionExpiryDuration), () {
      if (_paymentInProgress) {
        return;
      }
      cancelData();
    });
  }

  @override
  void initState() {
    super.initState();

    // Show retry error toast if present
    if (kIsWeb && html.window.localStorage['paymentRetry'] == '1') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Last payment attempt failed. Please try again.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      });
      html.window.localStorage.remove('paymentRetry');
    }

    _razorpay = Razorpay();
    _razorpay.on(RazorpayEvents.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(RazorpayEvents.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(RazorpayEvents.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    _fetchOrderData();
    _startSessionTimer(sessionExpiry);
  }

  void _resetSessionTimer(int sessionExpiryDuration) {
    _sessionTimer?.cancel();
    _startSessionTimer(sessionExpiryDuration);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    try {
      _razorpay.clear();
      _sessionTimer?.cancel();
    } catch (_) {}

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
        if (mounted) {
          setState(() {
            _sessionExpired = true;
            loading = false;
          });
          CommonMethods.showSessionExpiredDialog(context);
        }
      }
    } catch (e) {
      _showError("Unable to fetch order");
    }
  }

  Future<void> cancelOrderData() async {
    final url = Uri.parse('${Urls.cancelOrder}/${widget.secureKey}');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        setState(() {
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
      'amount': (orderData!['amount'] * 100).toInt(),
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
      log("Checkout failed: $e");
      Fluttertoast.showToast(msg: "Unable to start payment.");
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    _paymentInProgress = false; // payment done
    log("✅ Payment ID: ${response.paymentId}");
    Fluttertoast.showToast(msg: "Payment successful!");

    try {
      _razorpay.clear();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (kIsWeb) {
      // Replace current history entry with /homescreen
      html.window.history
          .replaceState(null, 'Home', AppRouteConstants.homeScreen);

      // Navigate to home screen with disableBack true by passing extra param or query param

      // Since GoRouter doesn't support widget params directly on .go(),
      // one simple way is to pass a query param, e.g. '/homescreen?disableBack=1'
      context.go('${AppRouteConstants.homeScreen}?disableBack=1');
    } else {
      context.go(AppRouteConstants.homeScreen);
    }
  }

  Future<void> _onPaymentError(PaymentFailureResponse response) async {
    _paymentInProgress = false;

    String errorMessage;
    switch (response.code) {
      case 0:
        errorMessage = "Network error. Please check your internet.";
        break;
      case 1:
        errorMessage = "Invalid payment details provided.";
        break;
      case 2:
        errorMessage = "Payment cancelled by user.";
        break;
      case 4:
        errorMessage = "Secure connection error. Please try again.";
        break;
      default:
        errorMessage = "Payment failed. Please try again.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(errorMessage, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    final now = DateTime.now();
    final elapsed = _paymentStartTime != null
        ? now.difference(_paymentStartTime!)
        : Duration.zero;
    final maxPaymentDuration = Duration(minutes: sessionExpiry);

    if (response.code == 2) {
      if (elapsed >= maxPaymentDuration) {
        // Session expired because payment timed out or user cancelled
        await cancelData();
      } else if (elapsed < maxPaymentDuration) {
        int remaining = sessionExpiry - elapsed.inMinutes;
        if (remaining > 0) {
          _resetSessionTimer(remaining);
        }
        _resetSessionTimer(remaining);
      }
      return;
    }

    try {
      _razorpay.clear();
    } catch (_) {}

    if (kIsWeb) {
      // Save retry info in localStorage
      html.window.localStorage['paymentRetry'] = '1';
      // Reload page to force close Razorpay popup
      html.window.location.reload();
      return; // Don't navigate now, wait for reload
    }
  }

  Future<void> _onExternalWallet(ExternalWalletResponse response) async {
    _paymentInProgress = false; // payment done via external wallet
    Fluttertoast.showToast(msg: "Payment successful!");

    try {
      _razorpay.clear();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    context.go(AppRouteConstants.orders);
  }

  void _showError(String message) {
    Fluttertoast.showToast(msg: message);
    //context.go('/404');
  }

  Widget _copyRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child:
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
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
                child: Image.network(orderData!['imageUrl'],
                    height: 180, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text("Hi ${orderData!['name']}",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _infoTile("Order No", orderData!['orderId'], copyable: true),
            _infoTile("Mobile", orderData!['mobileno']),
            _infoTile("Amount", "₹${orderData!['amount']}"),
            if (orderData!.containsKey('upiId'))
              _infoTile("UPI ID", orderData!['upiId'], copyable: true),
            if (orderData!.containsKey('createdAt'))
              _infoTile("Created On",
                  CommonMethods.formatDate(orderData!['createdAt'])),
            if (orderData!.containsKey('status'))
              _infoTile(
                  "Status", orderData!['status'].toString().toUpperCase()),
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
          SizedBox(
            width: 100,
            child: Text("$title:",
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: copyable ? _copyRow(title, value) : Text(value),
          ),
        ],
      ),
    );
  }

  void _handlePayNow() {
    if (_sessionExpired) {
      CommonMethods.showSessionExpiredDialog(context);
      return;
    }
    _paymentStartTime = DateTime.now(); // record start time
    _paymentInProgress = true; // Mark payment started
    _openCheckout();
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
        controller: _scrollController,
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
                  foregroundColor: Colors.black,
                ),
                onPressed: _sessionExpired ? null : _handlePayNow,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future cancelData() async {
    cancelOrderData();
    setState(() {
      _sessionExpired = true;
    });
    if (mounted) {
      CommonMethods.showSessionExpiredDialog(context);
    }
  }
}
