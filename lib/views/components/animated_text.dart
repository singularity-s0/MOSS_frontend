import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:openchat_frontend/utils/syntax_highlight.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:openchat_frontend/views/components/chat_ui/widgets/state/inherited_chat_theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AnimatedTextMessage extends StatefulWidget {
  final types.TextMessage message;
  final int speed;

  final bool animate;

  // Show a widget below the text when the animation is finished
  final Widget? bottomWidget;

  const AnimatedTextMessage({
    super.key,
    required this.message,
    this.speed = 100,
    this.animate = true,
    this.bottomWidget,
  });

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
        duration: Duration(
            milliseconds: ((widget.message.metadata!['currentText'] ??
                            widget.message.text)
                        .length -
                    widget.message.metadata!['animatedIndex'] as int) *
                widget.speed),
      );
      _characterLocation = IntTween(
        begin: widget.message.metadata!['animatedIndex'] as int,
        end: (widget.message.metadata!['currentText'] ?? widget.message.text)
            .length,
      ).animate(_controller);
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedTextMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate &&
        (widget.message.metadata!['animatedIndex'] as int) <
            (widget.message.metadata!['currentText'] ?? widget.message.text)
                .length) {
      // New characters have been feeded to the widget
      // so we need to cancel the old animation and start a new one
      _controller.stop();
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: ((widget.message.metadata!['currentText'] ??
                            widget.message.text)
                        .length -
                    min(_characterLocation.value,
                        widget.message.metadata!['animatedIndex'] as int)) *
                widget.speed),
      );
      _characterLocation = IntTween(
        begin: min(_characterLocation.value,
            widget.message.metadata!['animatedIndex'] as int),
        end: (widget.message.metadata!['currentText'] ?? widget.message.text)
            .length,
      ).animate(_controller);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = InheritedChatTheme.of(context).theme;
    final bodyLinkTextStyle = user.id == widget.message.author.id
        ? InheritedChatTheme.of(context).theme.sentMessageBodyLinkTextStyle
        : InheritedChatTheme.of(context).theme.receivedMessageBodyLinkTextStyle;
    final bodyTextStyle = user.id == widget.message.author.id
        ? theme.sentMessageBodyTextStyle
        : theme.receivedMessageBodyTextStyle;
    final boldTextStyle = user.id == widget.message.author.id
        ? theme.sentMessageBodyBoldTextStyle
        : theme.receivedMessageBodyBoldTextStyle;
    if (widget.animate) {
      return AnimatedBuilder(
          animation: _characterLocation,
          builder: (context, child) {
            var submessage = (widget.message.metadata!['currentText'] ??
                    widget.message.text ??
                    "")
                .substring(
                    0,
                    min<int>(
                        _characterLocation.value,
                        (widget.message.metadata!['currentText'] ??
                                widget.message.text ??
                                "")
                            .length));
            widget.message.metadata!['animatedIndex'] =
                _characterLocation.value;
            return Theme(
                data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                  selectionColor: user.id == widget.message.author.id
                      ? theme.sentMessageSelectionColor
                      : theme.receivedMessageSelectionColor,
                )),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        softLineBreak: true,
                        data: submessage,
                        styleSheet: MarkdownStyleSheet(
                          p: bodyTextStyle,
                          a: bodyLinkTextStyle,
                          strong: boldTextStyle,
                          blockquote: bodyTextStyle,
                        ),
                        onTapLink: (text, href, title) =>
                            launchUrlString(href!),
                        inlineSyntaxes: [STXHtmlSyntax()],
                        builders: {
                          'code': CodeElementBuilder(),
                          'html': SimpleHtmlBuilder(bodyTextStyle.copyWith(
                              color: theme.primaryColor)),
                        },
                        selectionColor:
                            Theme.of(context).textSelectionTheme.selectionColor,
                      ),
                      if (widget.message.metadata?["innerThoughts"] != null)
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Tooltip(
                              message:
                                  widget.message.metadata!["innerThoughts"],
                              child: Icon(Icons.lightbulb_outlined,
                                  size: 16,
                                  color: Theme.of(context).primaryColor),
                            ))
                    ],
                  ),
                ));
          });
    } else {
      return Theme(
        data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
          selectionColor: user.id == widget.message.author.id
              ? theme.sentMessageSelectionColor
              : theme.receivedMessageSelectionColor,
        )),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                softLineBreak: true,
                data: widget.message.metadata!['currentText'] ??
                    widget.message.text,
                styleSheet: MarkdownStyleSheet(
                  p: bodyTextStyle,
                  a: bodyLinkTextStyle,
                  strong: boldTextStyle,
                  blockquote: bodyTextStyle,
                ),
                inlineSyntaxes: [STXHtmlSyntax()],
                onTapLink: (text, href, title) => launchUrlString(href!),
                builders: {
                  'code': CodeElementBuilder(),
                  'html': SimpleHtmlBuilder(bodyTextStyle),
                },
                selectionColor:
                    Theme.of(context).textSelectionTheme.selectionColor,
              ),
              if (widget.message.metadata?["innerThoughts"] != null)
                Align(
                    alignment: Alignment.bottomRight,
                    child: Tooltip(
                      message: widget.message.metadata!["innerThoughts"],
                      child: Icon(Icons.lightbulb_outlined,
                          size: 16, color: Theme.of(context).primaryColor),
                    ))
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _controller.stop();
      _controller.dispose();
    }
    super.dispose();
  }
}
