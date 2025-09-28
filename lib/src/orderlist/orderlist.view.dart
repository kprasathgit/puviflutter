import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List orders = [];
  bool loading = true;
  String? error;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final username = StorageUtil.mobile;

    if (username == null) {
      context.go(AppRouteConstants.login);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('${Urls.orderMappingUrl}/orders?userId=$username'),
      );

      if (res.statusCode == 200) {
        setState(() {
          orders = jsonDecode(res.body);
          loading = false;
        });
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
      setState(() {
        error = "Error fetching orders: $e";
        loading = false;
      });
    }
  }

  Widget _buildOrderTile(Map<String, dynamic> o, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: theme.cardColor, // adapts to light/dark mode
      title: Text(
        "Order ID: ${o['orderId'] ?? '--'}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Amount: ₹${o['amount'] ?? '--'}",
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          Text(
            "Status: ${o['orderStatus'] ?? 'Pending'}",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: theme.iconTheme.color),
      onTap: () {
        final secureKey = o['orderId'];
        if (secureKey != null) {
          context.push('/order-detail/$secureKey');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Orders")),
      body: KeyboardScrollable(
        controller: _scrollController,
        child: Builder(
          builder: (context) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (error != null) {
              return Center(
                child: Text(
                  error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              );
            }

            if (orders.isEmpty) {
              return Center(
                child: Text(
                  "No Orders Found",
                  style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500),
                ),
              );
            }

            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _buildOrderTile(orders[i], theme),
            );
          },
        ),
      ),
    );
  }
}
