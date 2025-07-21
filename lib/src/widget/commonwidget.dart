import 'package:flutter/material.dart';

class CommonWidget {
  static void showTopToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 1),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    IconData? icon,
  }) {
    final overlay = Overlay.of(context);
    final theme = Theme.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) {
        final isSmallScreen = MediaQuery.of(context).size.width < 500;
        return Positioned(
          top: isSmallScreen ? 30 : 50,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) Icon(icon, color: textColor, size: 20),
                    if (icon != null) const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}
