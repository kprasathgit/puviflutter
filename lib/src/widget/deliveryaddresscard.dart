import 'package:flutter/material.dart';
import 'package:puvi/src/common/apiservice.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/common/urls.dart';
import 'package:puvi/src/models/user.dart';

class DeliveryAddressCard extends StatefulWidget {
  const DeliveryAddressCard({super.key});

  @override
  State<DeliveryAddressCard> createState() => _DeliveryAddressCardState();
}

class _DeliveryAddressCardState extends State<DeliveryAddressCard> {
  User? _user;
  bool _isEditing = false;
  bool _isSaving = false;
  final _addressController = TextEditingController();

  bool get hasAddress =>
      _user != null && _user!.address != null && _user!.address!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageUtil.getUserLocally();
    setState(() {
      _user = user;
      _addressController.text = user?.address ?? "";
    });
  }

  Future<void> _saveAddress() async {
    if (_user == null) return;
    setState(() => _isSaving = true);

    final userDetails = {
      'username': _user!.username,
      'address': _addressController.text.trim(),
    };

    final result = await ApiService.post<User>(
      url: Urls.updateUser,
      body: userDetails,
      fromJson: (data) => User.fromMap(data),
    );

    setState(() => _isSaving = false);

    if (result.status && result.returnObject != null) {
      await StorageUtil.saveUserLocally(result.returnObject!);
      setState(() {
        _user = result.returnObject!;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address updated successfully ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? "Failed to update address")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Deliver To",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text((_user!.name ?? '').trim(),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("📞 ${_user!.username ?? ''}"),
            if (hasAddress) Text("📍 ${_user!.address}"),
            const SizedBox(height: 12),

            // Editing UI
            if (_isEditing) ...[
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Enter new address",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: 450,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    child: _isSaving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Save"),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              )
            ],

            if (!_isEditing)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: Text(hasAddress ? "Change Address" : "Add Address"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
