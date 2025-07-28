import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:puvi/src/common/urls.dart';
import 'package:go_router/go_router.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List orders = [];
  bool loading = true;

  final String userId = '8489707130'; // or fetch dynamically from login/session

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('${Urls.orderMappingUrl}/orders?userId=$userId'));

      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          loading = false;
        });
      } else {
        throw Exception("Failed to fetch orders");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());
    if (orders.isEmpty) return Center(child: Text('No Orders Found'));

    return Scaffold(
      appBar: AppBar(title: const Text("Your Orders")),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final o = orders[i];
          return ListTile(
            title: Text("Order ID: ${o['orderId']}"),
            subtitle: Text("₹${o['amount']}"),
            trailing: Text(o['orderstatus'] ?? ''),
            onTap: () {
              context.push('/order-detail/${o['secureKey']}');
            },
          );
        },
      ),
    );
  }
}
