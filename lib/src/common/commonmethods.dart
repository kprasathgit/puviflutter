import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:puvi/project/routes/app_route_constants.dart';
import 'package:puvi/src/cart/cart.controller.dart';
import 'package:puvi/src/models/product.dart';
import 'package:puvi/src/models/user.dart';
import 'package:intl/intl.dart';

class CommonMethods {
  static String buildRedirectUrl(
    String basePath, {
    String? next,
    String? flow,
    String? slug,
  }) {
    final params = <String, String>{};
    if (next != null && next.isNotEmpty) params['next'] = next;
    if (flow != null && flow.isNotEmpty) params['flow'] = flow;
    if (slug != null && slug.isNotEmpty) params['slug'] = slug;

    if (params.isEmpty) return basePath;

    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$basePath?$queryString';
  }

  static Map<String, dynamic> fromSingleProduct({
    required String uid,
    required User user,
    required Product product,
    required int qty,
    required double amount,
  }) {
    return {
      'uid': uid,
      'userName': user.username,
      'name': user.name,
      'phone': user.mobileno,
      'shippingAddress': user.address,
      'amount': amount,
      'listProCode': [product.procode],
      'qtyList': [qty],
      'priceList': [product.price],
    };
  }

  static Map<String, dynamic> fromCart({
    required String uid,
    required User user,
    required List<CartItem> cartItems,
  }) {
    return {
      'uid': uid,
      'userName': user.username,
      'name': user.name,
      'phone': user.mobileno,
      'shippingAddress': user.address,
      'amount': cartItems.fold(0.0, (sum, item) => sum + item.total),
      'listProCode': cartItems.map((e) => e.product.procode).toList(),
      'qtyList': cartItems.map((e) => e.qty).toList(),
      'priceList': cartItems.map((e) => e.product.price).toList(),
    };
  }

  static String formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return "Invalid date";
    }
  }

  static void showToast(
    String message, {
    Toast? toastLength,
    ToastGravity? toastGravity,
    Color? backgroundColor,
    Color? textColor,
    dynamic webPosition,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength ?? Toast.LENGTH_SHORT,
      gravity: toastGravity ?? ToastGravity.TOP,
      backgroundColor: backgroundColor ?? Colors.green.shade300,
      textColor: textColor ?? Colors.white,
      fontSize: 16.0,
      // Add vertical offset (adjust as needed)
      webPosition:
          webPosition ?? "center", // for web: "top", "center", "bottom"
      // for Android/iOS, use `timeInSecForIosWeb` for duration control below
      timeInSecForIosWeb: toastLength == Toast.LENGTH_LONG ? 3 : 2,
    );
  }

  static Future<void> showSessionExpiredDialog(BuildContext context) async {
    // Show modal dialog, no dismiss except button
    await showDialog(
      context: context,
      barrierDismissible: false, // user can't tap outside to dismiss
      builder: (context) {
        return AlertDialog(
          title: const Text("Session Expired"),
          content: const Text(
              "Your session has expired due to inactivity. Please start again."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRouteConstants.homeScreen); // go home
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
