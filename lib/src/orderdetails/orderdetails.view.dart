import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:puvi/src/common/ordertracking.dart';
import 'package:puvi/src/common/urls.dart';

class OrderDetailScreen extends StatefulWidget {
  final String secureKey;
  const OrderDetailScreen({required this.secureKey, super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? order;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  Future<void> fetchOrder() async {
    try {
      final url = Uri.parse(
          '${Urls.orderMappingUrl}/${widget.secureKey}/${'tracking'}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          order = jsonDecode(response.body);
          loading = false;
        });
      } else {
        throw Exception("Order not found");
      }
    } catch (e) {
      print("Fetch error: $e");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (order == null) return const Center(child: Text("Order not found"));

    final items = order!['items'] ?? [];
    final trackingSteps = order!['trackingSteps'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Order Info
            Text("Order ID: ${order!['orderId']}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Status: ${order!['orderstatus']}"),
            Text("Amount: ₹${order!['amount']}"),
            Text("Created: ${order!['createdAt'] ?? 'N/A'}"),
            const SizedBox(height: 16),

            // 🔹 Items List
            const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map<Widget>((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item['proname'] ?? ''),
                subtitle: Text("Qty: ${item['qty']}"),
                trailing: Text("₹${item['price']}"),
              );
            }).toList(),

            const SizedBox(height: 20),

            // 🔹 Tracking Section
            const Text("Delivery Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            OrderTrackingSwitchable(
              steps: trackingSteps.map<Map<String, dynamic>>((step) {
                bool? completed = step['completed'];
                return {
                  'label': step['label'] ?? '',
                  'completed': completed ?? false,
                  'timestamp': completed != null &&
                          completed &&
                          step['timestamp'] != null
                      ? step['timestamp']
                      : '',
                };
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
