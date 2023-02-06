import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:openchat_frontend/views/components/animated_text.dart';

const user = types.User(id: 'user');
const reply = types.User(id: 'moss');

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', scale: 6.5),
      ),
      body: const ChatView());
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  List<types.Message> _messages = [];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          user: user,
          showUserAvatars: true,
          theme: DefaultChatTheme(
            primaryColor: Theme.of(context).primaryColor,
          ),
          avatarBuilder: (userId) {
            if (userId == reply.id) {
              return Image.asset(
                'assets/images/avatar.png',
                fit: BoxFit.cover,
                scale: 5.5,
                isAntiAlias: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  return Padding(
                      padding: const EdgeInsets.only(right: 8), child: child);
                },
              );
            }
            return const SizedBox();
          },
          onSendPressed: (types.PartialText message) async {
            setState(() {
              _messages.insert(
                  0,
                  types.TextMessage(
                      author: user,
                      text: message.text,
                      metadata: {
                        'animatedIndex': 0
                      }, // DO NOT mark this as constant
                      id: DateTime.now().toString(),
                      type: types.MessageType.text));
            });
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() {
              _messages.insert(
                  0,
                  types.TextMessage(
                      author: reply,
                      text: "This should be a response to '${message.text}'",
                      metadata: {
                        'animatedIndex': 0
                      }, // DO NOT mark this as constant
                      id: DateTime.now().toString(),
                      type: types.MessageType.text));
            });
          },
          textMessageBuilder: (msg,
              {required messageWidth, required showName}) {
            if (msg.author == reply) {
              return AnimatedTextMessage(
                message: msg,
                speed: 100,
                finishingWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: Theme.of(context)
                            .buttonTheme
                            .colorScheme
                            ?.onSurface
                            .withAlpha(130),
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.thumb_down,
                        size: 16,
                        color: Theme.of(context)
                            .buttonTheme
                            .colorScheme
                            ?.onSurface
                            .withAlpha(130),
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            } else {
              return TextMessage(
                emojiEnlargementBehavior: EmojiEnlargementBehavior.never,
                hideBackgroundOnEmojiMessages: false,
                showName: false,
                message: msg,
                usePreviewData: false,
              );
            }
          },
        ),
      );
}
