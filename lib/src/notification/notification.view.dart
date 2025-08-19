import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvi/src/notification/notification.controller.dart';
import 'package:puvi/src/models/usernotification.dart';
import 'package:puvi/src/common/keyboardscrollable.dart';

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

  /// Track which notifications are collapsed; default is expanded
  final Set<String> _collapsedIds = {};

  /// Focus node for keyboard scroll
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

    // Request focus so KeyboardScrollable works immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleCollapse(int? id) {
    final key = id?.toString() ?? '';
    setState(() {
      if (_collapsedIds.contains(key)) {
        _collapsedIds.remove(key);
      } else {
        _collapsedIds.add(key);
      }
    });
  }

  bool _isCollapsed(int? id) => _collapsedIds.contains(id?.toString() ?? '');

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
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                    ),
                    // if (notifController.unreadCount > 0)
                    //   TextButton(
                    //     onPressed: notifController.markAllSeen,
                    //     child: Text(
                    //       'Mark all seen (${notifController.unreadCount})',
                    //       style: const TextStyle(fontSize: 14),
                    //     ),
                    //   ),
                    // const Divider(height: 1),

                    // Notification List
                    Expanded(
                      child: KeyboardScrollable(
                        autofocus: true,
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: notifController.notifications.length,
                          itemBuilder: (context, index) {
                            final n = notifController.notifications[index];
                            final isCollapsed = _isCollapsed(n.id);
                            final bgColor =
                                n.seen ? Colors.white : Colors.green[50];

                            return InkWell(
                              onTap: () {
                                _toggleCollapse(n.id);
                                if (!n.seen) {
                                  n.seen = true;
                                  notifController.notifyListeners();

                                  // TODO: Call backend markSeen(n.uniqueKey, uid)
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      bgColor, // <-- seen/unseen reflected here
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title ?? 'No Title',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: n.seen
                                                  ? Colors.grey[800]
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          isCollapsed
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          size: 20,
                                          color: Colors.grey[700],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    if (!isCollapsed)
                                      Text(
                                        n.body ?? '',
                                        style: const TextStyle(fontSize: 14),
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
