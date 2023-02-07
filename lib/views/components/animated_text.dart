import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class AnimatedTextMessage extends StatefulWidget {
  final types.TextMessage message;
  final int speed;

  final bool animate;

  // Show a widget below the text when the animation is finished
  final Widget? bottomWidget;

  const AnimatedTextMessage({
    Key? key,
    required this.message,
    this.speed = 100,
    this.animate = true,
    this.bottomWidget,
  }) : super(key: key);

  @override
  AnimatedTextMessageState createState() => AnimatedTextMessageState();
}

class AnimatedTextMessageState extends State<AnimatedTextMessage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterLocation;
  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: widget.message.text.length * widget.speed),
      );
      _characterLocation = IntTween(
        begin: widget.message.metadata!['animatedIndex'] as int,
        end: widget.message.text.length,
      ).animate(_controller);
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedTextMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate) {
      // New characters have been feeded to the widget
      // so we need to cancel the old animation and start a new one
      _controller.stop();
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: widget.message.text.length * widget.speed),
      );
      _characterLocation = IntTween(
        begin: min(_characterLocation.value,
            widget.message.metadata!['animatedIndex'] as int),
        end: widget.message.text.length,
      ).animate(_controller);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animate) {
      return AnimatedBuilder(
        animation: _characterLocation,
        builder: (context, child) {
          var submessage = widget.message.text.substring(
              0, min(_characterLocation.value, widget.message.text.length));
          var newmsg =
              widget.message.copyWith(text: submessage) as types.TextMessage;
          widget.message.metadata!['animatedIndex'] = _characterLocation.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextMessage(
                emojiEnlargementBehavior: EmojiEnlargementBehavior.never,
                hideBackgroundOnEmojiMessages: false,
                showName: false,
                message: newmsg,
                usePreviewData: false,
              ),
              if (_characterLocation.value == widget.message.text.length &&
                  widget.bottomWidget != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [widget.bottomWidget!],
                ),
            ],
          );
        },
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextMessage(
            emojiEnlargementBehavior: EmojiEnlargementBehavior.never,
            hideBackgroundOnEmojiMessages: false,
            showName: false,
            message: widget.message,
            usePreviewData: false,
          ),
          if (widget.bottomWidget != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [widget.bottomWidget!],
            ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
