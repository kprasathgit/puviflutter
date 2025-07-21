import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final form = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Info')),
      body: Form(
        key: form,
        child: Column(children: [
          TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              validator: (v) => v?.length != 10 ? 'Enter 10 digits' : null),
          TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          ElevatedButton(
            onPressed: () {
              if (form.currentState?.validate() ?? false) {
                context.go('/payment', extra: {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'address': addressController.text
                });
              }
            },
            child: const Text('Continue to Payment'),
          ),
        ]),
      ),
    );
  }
}
