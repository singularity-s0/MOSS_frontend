import 'dart:math';

import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    super.key,
    this.bubbleColor = const Color(0xFF646b7f),
    this.flashingCircleDarkColor,
    this.flashingCircleBrightColor,
  });

  final Color bubbleColor;
  final Color? flashingCircleDarkColor;
  final Color? flashingCircleBrightColor;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late AnimationController _repeatingController;
  final List<Interval> _dotIntervals = const [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1.0),
  ];

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _showIndicator();
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _repeatingController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 750)
      ..forward();
    _repeatingController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return StatusBubble(
      repeatingController: _repeatingController,
      dotIntervals: _dotIntervals,
      flashingCircleDarkColor: widget.flashingCircleDarkColor ??
          Theme.of(context).colorScheme.secondary,
      flashingCircleBrightColor:
          widget.flashingCircleBrightColor ?? const Color(0xFFaec1dd),
    );
  }
}

class StatusBubble extends StatelessWidget {
  const StatusBubble({
    super.key,
    required this.repeatingController,
    required this.dotIntervals,
    required this.flashingCircleBrightColor,
    required this.flashingCircleDarkColor,
  });

  final AnimationController repeatingController;
  final List<Interval> dotIntervals;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 40,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlashingCircle(
              index: 0,
              repeatingController: repeatingController,
              dotIntervals: dotIntervals,
              flashingCircleDarkColor: flashingCircleDarkColor,
              flashingCircleBrightColor: flashingCircleBrightColor,
            ),
            FlashingCircle(
              index: 1,
              repeatingController: repeatingController,
              dotIntervals: dotIntervals,
              flashingCircleDarkColor: flashingCircleDarkColor,
              flashingCircleBrightColor: flashingCircleBrightColor,
            ),
            FlashingCircle(
              index: 2,
              repeatingController: repeatingController,
              dotIntervals: dotIntervals,
              flashingCircleDarkColor: flashingCircleDarkColor,
              flashingCircleBrightColor: flashingCircleBrightColor,
            ),
          ],
        ),
      ),
    );
  }
}

class FlashingCircle extends StatelessWidget {
  const FlashingCircle({
    super.key,
    required this.index,
    required this.repeatingController,
    required this.dotIntervals,
    required this.flashingCircleBrightColor,
    required this.flashingCircleDarkColor,
  });

  final int index;
  final AnimationController repeatingController;
  final List<Interval> dotIntervals;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repeatingController,
      builder: (context, child) {
        final circleFlashPercent = dotIntervals[index].transform(
          repeatingController.value,
        );
        final circleColorPercent = sin(pi * circleFlashPercent);

        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
              flashingCircleDarkColor,
              flashingCircleBrightColor,
              circleColorPercent,
            ),
          ),
        );
      },
    );
  }
}
