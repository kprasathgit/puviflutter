import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardScrollable extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final bool autofocus;

  const KeyboardScrollable({
    super.key,
    required this.child,
    this.controller,
    this.autofocus = true,
  });

  @override
  State<KeyboardScrollable> createState() => _KeyboardScrollableState();
}

class _KeyboardScrollableState extends State<KeyboardScrollable> {
  late final ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      const double scrollStep = 60.0;
      const double pageStep = 300.0;

      if (!_scrollController.hasClients) return KeyEventResult.ignored;

      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double minScroll = _scrollController.position.minScrollExtent;
      final double currentOffset = _scrollController.offset;

      void smoothScrollTo(double offset) {
        _scrollController.animateTo(
          offset.clamp(minScroll, maxScroll),
          duration: const Duration(milliseconds: 30 ),
          curve: Curves.easeOutCubic,
        );
      }

      switch (event.logicalKey.keyLabel) {
        case 'Arrow Down':
          smoothScrollTo(currentOffset + scrollStep);
          return KeyEventResult.handled;
        case 'Arrow Up':
          smoothScrollTo(currentOffset - scrollStep);
          return KeyEventResult.handled;
        case 'Page Down':
          smoothScrollTo(currentOffset + pageStep);
          return KeyEventResult.handled;
        case 'Page Up':
          smoothScrollTo(currentOffset - pageStep);
          return KeyEventResult.handled;
        case 'Home':
          smoothScrollTo(minScroll);
          return KeyEventResult.handled;
        case 'End':
          smoothScrollTo(maxScroll);
          return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: widget.autofocus,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
          },
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          interactive: true,
          trackVisibility: true,
          thickness: 12,
          radius: const Radius.circular(8),
          scrollbarOrientation: ScrollbarOrientation.right,
          child: PrimaryScrollController(
            controller: _scrollController,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
