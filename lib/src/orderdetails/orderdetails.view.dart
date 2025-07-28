import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      final url = Uri.parse('${Urls.fetchOrder}/${widget.secureKey}');
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
    if (loading) return Center(child: CircularProgressIndicator());

    if (order == null) return Center(child: Text("Order not found"));

    final items = order!['items'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: ${order!['orderId']}"),
            Text("Status: ${order!['orderstatus']}"),
            Text("Amount: ₹${order!['amount']}"),
            Text("Created: ${order!['createdAt'] ?? 'N/A'}"),
            const SizedBox(height: 16),
            const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map<Widget>((item) {
              return ListTile(
                title: Text(item['productName'] ?? 'Unnamed'),
                subtitle: Text("Qty: ${item['qty']}"),
                trailing: Text("₹${item['price']}"),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
