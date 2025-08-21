import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';
import 'package:puvi/src/notification/notification.controller.dart';

class NotificationPanel extends StatefulWidget {
  final VoidCallback onClose;

  const NotificationPanel({super.key, required this.onClose});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offset;
  final Set<String> _collapsedIds = {};
  final FocusNode _focusNode = FocusNode();
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offset = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _toggleCollapse(String key) {
    setState(() {
      if (_collapsedIds.contains(key)) {
        _collapsedIds.remove(key);
      } else {
        _collapsedIds.add(key);
      }
    });
  }

  bool _isCollapsed(String key) => _collapsedIds.contains(key);

  /// Format relative time like "5 min ago", "3 hr ago"
  String _timeAgo(DateTime? date) {
    if (date == null) return ""; // show nothing if null

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    if (diff.inDays < 30) {
      return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
    }
    return "${diff.inDays ~/ 30} month${(diff.inDays ~/ 30) > 1 ? 's' : ''} ago";
  }

  @override
  Widget build(BuildContext context) {
    final notifController = Provider.of<NotificationController>(context);

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.transparent),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: _offset,
              child: Container(
                width: 420,
                height: double.infinity,
                color: Colors.white,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.green[700],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              const Text(
                                'Notifications',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              if (notifController.unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    notifController.unreadCount.toString(),
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                    ),

                    // Mark all seen
                    if (notifController.unreadCount > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 12, top: 8, bottom: 4),
                          child: TextButton.icon(
                            onPressed: notifController.markAllSeen,
                            icon: const Icon(Icons.done_all, size: 18),
                            label: Text(
                              'Mark all as seen',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                        ),
                      ),

                    const Divider(height: 1),

                    // Notification list
                    Expanded(
                      child: notifController.notifications.isEmpty
                          ? const Center(
                              child: Text(
                                "No notifications",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            )
                          : KeyboardScrollable(
                              autofocus: true,
                              controller: _scrollController,
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(8),
                                itemCount: notifController.notifications.length,
                                itemBuilder: (context, index) {
                                  final n =
                                      notifController.notifications[index];
                                  final collapsed = _isCollapsed(
                                      n.id?.toString() ?? n.uniquekey);
                                  final bgColor =
                                      n.seen ? Colors.white : Colors.green[50];

                                  return InkWell(
                                    onTap: () async {
                                      _toggleCollapse(n.id?.toString() ??
                                          n.uniquekey);
                                      if (!n.seen) {
                                        await notifController.markSeen(n);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  n.title,
                                                  style: TextStyle(
                                                    fontWeight: n.seen
                                                        ? FontWeight.normal
                                                        : FontWeight.bold,
                                                    fontSize: 16,
                                                    color: n.seen
                                                        ? Colors.grey[800]
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                _timeAgo(n.createdtime),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Icon(
                                                collapsed
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons.keyboard_arrow_up,
                                                size: 20,
                                                color: Colors.grey[700],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          if (!collapsed)
                                            Text(
                                              n.body,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: n.seen
                                                    ? Colors.grey[700]
                                                    : Colors.black,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
