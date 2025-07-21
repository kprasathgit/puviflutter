import 'dart:async';
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
  Timer? _holdScrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _holdScrollTimer?.cancel();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyRepeatEvent || event is KeyDownEvent) {
      const scrollStep = 80.0;
      const pageStep = 300.0;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final minScroll = _scrollController.position.minScrollExtent;
      final currentOffset = _scrollController.offset;

      void scrollTo(double offset) {
        _scrollController.animateTo(
          offset.clamp(minScroll, maxScroll),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }

      switch (event.logicalKey.keyLabel) {
        case 'Arrow Down':
          scrollTo(currentOffset + scrollStep);
          return KeyEventResult.handled;
        case 'Arrow Up':
          scrollTo(currentOffset - scrollStep);
          return KeyEventResult.handled;
        case 'Page Down':
          scrollTo(currentOffset + pageStep);
          return KeyEventResult.handled;
        case 'Page Up':
          scrollTo(currentOffset - pageStep);
          return KeyEventResult.handled;
        case 'Home':
          scrollTo(minScroll);
          return KeyEventResult.handled;
        case 'End':
          scrollTo(maxScroll);
          return KeyEventResult.handled;
      }
    }

    if (event is KeyUpEvent) {
      _holdScrollTimer?.cancel();
      _holdScrollTimer = null;
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
          thickness: 14,
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
