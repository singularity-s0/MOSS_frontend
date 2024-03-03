import 'dart:async';

import 'package:flutter/material.dart';

class DelayShowWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration delay;

  const DelayShowWidget({
    super.key,
    required this.child,
    this.enabled = true,
    this.delay = const Duration(seconds: 2),
  });

  @override
  State<DelayShowWidget> createState() => _DelayShowWidgetState();
}

class _DelayShowWidgetState extends State<DelayShowWidget> {
  bool _show = true;
  Timer? _timer;

  void onTimer() {
    setState(() {
      _show = true;
    });
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
    if (_show == false && widget.enabled) {
      if (_timer != null) _timer!.cancel();
      _timer = Timer(widget.delay, onTimer);
    }
  }

  @override
  void didUpdateWidget(DelayShowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled) {
      setState(() {
        _show = false;
      });
      if (_timer != null) _timer!.cancel();
      _timer = Timer(widget.delay, onTimer);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox();
    return AnimatedSize(
      duration: const Duration(milliseconds: 700),
      curve: Curves.fastLinearToSlowEaseIn,
      child: _show ? widget.child : const SizedBox(),
    );
  }
}
