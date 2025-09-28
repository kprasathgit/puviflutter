import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
      final url =
          Uri.parse('${Urls.orderMappingUrl}/${widget.secureKey}/tracking');
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
      setState(() {
        loading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) return const Center(child: CircularProgressIndicator());

    if (order == null)
      return Center(
          child: Text("Order not found",
              style: TextStyle(color: theme.textTheme.bodyMedium?.color)));

    final items = order!['items'] ?? [];
    final trackingSteps = order!['trackingSteps'] ?? [];
    final totalAmount = order!['amount'] ?? '--';

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Order Info
            Text("Order ID: ${order!['orderId']}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color)),
            Text("Status: ${order!['orderstatus']}",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            Text("Created: ${_formatDate(order!['createdAt'])}",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 16),

            // 🔹 Items List
            Text("Items:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            ...items.map<Widget>((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: theme.brightness == Brightness.light
                          ? Colors.black.withOpacity(0.03)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item['imageurl'] != null
                          ? Image.network(
                              item['imageurl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: theme.dividerColor,
                              child: Icon(Icons.image,
                                  color: theme.iconTheme.color),
                            ),
                    ),
                    const SizedBox(width: 12),

                    // 🔹 Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['proname'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Qty: ${item['qty']}",
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${item['price']}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 12),

            // 🔹 Total Amount Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                    ? Colors.green.shade50
                    : Colors.green.shade900.withOpacity(0.3), // dark mode bg
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.brightness == Brightness.light
                      ? Colors.green.shade200
                      : Colors.green.shade700, // dark mode border
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color, // adaptive text
                    ),
                  ),
                  Text(
                    "₹$totalAmount",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.light
                          ? Colors.green.shade400
                          : Colors.green.shade300, // adaptive green
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Tracking Section
            Text("Delivery Status",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color)),
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
