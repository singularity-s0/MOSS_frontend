import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class AnimatedTextMessage extends StatefulWidget {
  final types.TextMessage message;
  final int speed;
  final VoidCallback? onFinished;

  // Show a widget below the text when the animation is finished
  final Widget finishingWidget;

  const AnimatedTextMessage({
    Key? key,
    required this.message,
    this.speed = 100,
    this.onFinished,
    this.finishingWidget = const SizedBox(),
  }) : super(key: key);

  @override
  AnimatedTextMessageState createState() => AnimatedTextMessageState();
}

class AnimatedTextMessageState extends State<AnimatedTextMessage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterLocation;

  void setFinishedCallback() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished?.call();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: widget.message.text.length * widget.speed),
    );
    _characterLocation = IntTween(
      begin: widget.message.metadata!['animatedIndex'] as int,
      end: widget.message.text.length,
    ).animate(_controller);
    setFinishedCallback();
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedTextMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    setFinishedCallback();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
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
            if (_characterLocation.value == widget.message.text.length)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [widget.finishingWidget],
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
