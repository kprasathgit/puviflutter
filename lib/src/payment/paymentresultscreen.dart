import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:puvi/src/common/urls.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String secureKey;
  const PaymentStatusScreen({required this.secureKey, super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  String statusMessage = "🔄 Checking payment status...";
  Timer? _pollTimer;
  int retryCount = 0;
  final int maxRetries = 5;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    try {
      final url = Uri.parse('${Urls.fetchOrder}/${widget.secureKey}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderStatus = data['orderStatus'];

        if (orderStatus == 'PAID') {
          setState(() {
            statusMessage = "🎉 Payment Successful!";
          });
          Future.delayed(const Duration(seconds: 2), () {
            context.go('/orders');
          });
        } else if (orderStatus == 'FAILED') {
          setState(() {
            statusMessage = "❌ Payment Failed. Please try again.";
          });
        } else {
          // PENDING or UNKNOWN — retry
          if (retryCount < maxRetries) {
            retryCount++;
            _pollTimer = Timer(const Duration(seconds: 3), _checkStatus);
          } else {
            setState(() {
              statusMessage = "⚠️ Still pending. Check orders later.";
            });
          }
        }
      } else {
        throw Exception("Failed to fetch order");
      }
    } catch (e) {
      setState(() {
        statusMessage = "❌ Error: ${e.toString()}";
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Status")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(statusMessage, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
