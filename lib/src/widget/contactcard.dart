import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class PuvipureContactCard extends StatelessWidget {
  const PuvipureContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsive width for tablets/web
    double maxWidth = width > 600 ? 450 : width;

    return Center(
      child: Container(
        width: maxWidth,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top handle
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "PUVI PURE — Contact Support",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            _dashedDivider(),

            const SizedBox(height: 16),

            /// ----------- PHONE 1 (NO LABELS) -------------
            _contactItem(
              icon: Icons.phone_in_talk_rounded,
              value: "+91 96984 15905",
              color: Colors.blue,
              onTap: () => html.window.open("tel:+919698415905", "_self"),
            ),

            /// ----------- PHONE 2 (NO LABELS) -------------
            _contactItem(
              icon: Icons.phone_android_rounded,
              value: "+91 63808 99802",
              color: Colors.green,
              onTap: () => html.window.open("tel:+916380899802", "_self"),
            ),

            /// ----------- EMAIL -------------
            _contactItem(
              icon: Icons.email_outlined,
              value: "m.anbumech007@gmail.com",
              color: Colors.deepPurple,
              onTap: () =>
                  html.window.open("mailto:m.anbumech007@gmail.com", "_self"),
            ),

            const SizedBox(height: 22),

            Center(
              child: Text(
                "We are happy to assist you anytime.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Contact Item (title removed)
  Widget _contactItem({
    required IconData icon,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Perfect dashed divider
  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 10).floor();
        return Row(
          children: List.generate(dashCount, (_) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 1.2,
                color: Colors.black26,
              ),
            );
          }),
        );
      },
    );
  }
}
