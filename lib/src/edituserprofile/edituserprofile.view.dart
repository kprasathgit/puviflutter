import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvi/src/common/storageutil.dart';
import 'package:puvi/src/models/user.dart';
import 'package:puvi/src/userdetails/userdetails.controller.dart';

class EditUserProfile extends StatefulWidget {
  const EditUserProfile({super.key});

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final address = TextEditingController();

  late UserDetailsController userDetailsController;

  bool loading = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    userDetailsController =
        Provider.of<UserDetailsController>(context, listen: false);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageUtil.getUserLocally();
    if (mounted) {
      setState(() {
        currentUser = user;
        if (user != null) {
          name.text = user.name ?? '';
          address.text = user.address ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    name.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide =
        MediaQuery.of(context).size.width > 700; // laptop/web breakpoint

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: EdgeInsets.all(isWide ? 32 : 16),
            elevation: isWide ? 8 : 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: isWide ? 32 : 20, horizontal: isWide ? 40 : 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Profile Icon + Title
                    Column(
                      children: [
                        CircleAvatar(
                          radius: isWide ? 50 : 40,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(Icons.person,
                              size: isWide ? 50 : 40,
                              color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Update Your Details",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Keep your profile up to date for better service",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.hintColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 🔹 Form Fields
                    _buildTextField(
                        controller: name,
                        label: "Full Name",
                        icon: Icons.person,
                        validator: (v) => v != null && v.isNotEmpty
                            ? null
                            : "Name is required"),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: address,
                      label: "Address",
                      icon: Icons.home,
                      maxLines: 2,
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 8) {
                          return "Address too short";
                        }
                        return null;
                      },
                    ),
                    // const SizedBox(height: 16),
                    // _buildTextField(
                    //   initialValue: currentUser?.mobileno ?? '',
                    //   label: "Mobile Number",
                    //   icon: Icons.phone,
                    //   readOnly: true,
                    //   suffix: const Icon(Icons.lock_outline, size: 18),
                    // ),
                    const SizedBox(height: 30),

                    // 🔹 Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: loading ? null : _saveProfile,
                            icon: loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: const Text("Save Changes"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    bool readOnly = false,
    Widget? suffix,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final updatedData = {
        'username': currentUser!.username!,
        'name': name.text.trim(),
        'address': address.text.trim(),
      };

      final updatedUser =
          await userDetailsController.updateUserProfile(updatedData);

      if (updatedUser == null) {
        throw Exception("Profile Updation Failed!");
      }

      await StorageUtil.saveUserLocally(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }
}
