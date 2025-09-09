import 'package:flutter/material.dart';

class OrderTrackingSwitchable extends StatelessWidget {
  final List<Map<String, dynamic>> steps;

  const OrderTrackingSwitchable({required this.steps, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 🔹 If screen width < 600 → Mobile → Horizontal
        if (constraints.maxWidth < 600) {
          return _OrderTrackingHorizontal(steps: steps);
        }
        // 🔹 Else → Desktop/Web → Vertical
        return _OrderTrackingVertical(steps: steps);
      },
    );
  }
}

/// 🔹 Horizontal Scrollable Tracker (Amazon style)
class _OrderTrackingHorizontal extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  const _OrderTrackingHorizontal({required this.steps});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final completed = step['completed'] as bool;
          final isLast = index == steps.length - 1;

          return Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: completed ? Colors.green : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: completed ? Colors.green : Colors.grey,
                    ),
                  ),
                  if (step['timestamp'] != null)
                    Text(
                      step['timestamp'],
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                ],
              ),
              if (!isLast)
                Container(
                  width: 50,
                  height: 2,
                  color: completed ? Colors.green : Colors.grey,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// 🔹 Vertical Timeline Tracker
class _OrderTrackingVertical extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  const _OrderTrackingVertical({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final completed = step['completed'] as bool;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: completed ? Colors.green : Colors.grey,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: completed ? Colors.green : Colors.grey,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['label'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: completed ? Colors.green : Colors.grey,
                    ),
                  ),
                  if (step['timestamp'] != null)
                    Text(
                      step['timestamp'],
                      style: const TextStyle(color: Colors.black54),
                    ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
