import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/common/urls.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}
class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _form = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Info')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                enabled: !isLoading,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: phoneController,
                enabled: !isLoading,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length != 10 ? 'Enter 10 digits' : null,
              ),
              TextFormField(
                controller: addressController,
                enabled: !isLoading,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Row with button + loader
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_form.currentState!.validate()) {
                              setState(() => isLoading = true);

                              final cartItems = context.read<CartController>().items;

                              final payload = {
                                'userId': 1,
                                'name': nameController.text,
                                'phone': phoneController.text,
                                'shippingAddress': addressController.text,
                                'amount': cartItems.fold(0.0, (sum, item) => sum + item.total),
                                'userName': phoneController.text,
                                'listProCode': cartItems.map((e) => e.product.procode).toList(),
                                'qtyList': cartItems.map((e) => e.qty).toList(),
                                'priceList': cartItems.map((e) => e.product.price).toList(),
                              };

                              try {
                                final res = await http.post(
                                  Uri.parse(Urls.createOrder),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode(payload),
                                );

                                if (res.statusCode == 200) {
                                  final json = jsonDecode(res.body);
                                  final secureKey = json['secureKey'];
                                  context.go('${AppRouteConstants.payment}/$secureKey');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Order creation failed')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              } finally {
                                if (mounted) setState(() => isLoading = false);
                              }
                            }
                          },
                    child: const Text('Continue to Payment'),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
