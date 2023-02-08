import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:openchat_frontend/views/components/animated_text.dart';
import 'package:openchat_frontend/views/history_page.dart';

const user = types.User(id: 'user');
const reply = types.User(id: 'moss');

const kTabletMasterContainerWidth = 370.0;
const kTabletSingleContainerWidth = 410.0;

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= 768.0;
}

class ChatPage extends StatelessWidget {
  // The state of this page records the "Topic" that the user is currently in
  // Children can use context.findAncestorStateOfType<ChatPageState>() to read and change this
  final ValueNotifier<String> currentTopic = ValueNotifier<String>('whatever');
  ChatPage({super.key});

  // Mobile UI
  Widget buildMobile(BuildContext context) => ValueListenableBuilder(
      valueListenable: currentTopic,
      builder: (context, value, child) => ChatView(topicId: value));

  // Desktop UI
  Widget buildDesktop(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: Row(
        children: [
          // Left View
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: kTabletMasterContainerWidth,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                clipBehavior: Clip.antiAlias,
                child: ValueListenableBuilder(
                    valueListenable: currentTopic,
                    builder: (context, value, child) =>
                        HistoryPage(selectedTopic: value)),
              ),
            ),
          ),
          // Right View
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width:
                MediaQuery.of(context).size.width - kTabletMasterContainerWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                clipBehavior: Clip.antiAlias,
                child: ValueListenableBuilder(
                    valueListenable: currentTopic,
                    builder: (context, value, child) =>
                        ChatView(topicId: value)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      isDesktop(context) ? buildDesktop(context) : buildMobile(context);
}

class ChatView extends StatefulWidget {
  final String topicId;
  const ChatView({super.key, required this.topicId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<types.Message> _messages = [
    const types.SystemMessage(
      text: "AIGC warning message here",
      id: "ai-alert",
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/logo.png', scale: 6.5),
        ),
        body: Chat(
          messages: _messages,
          user: user,
          showUserAvatars: false,
          theme: DefaultChatTheme(
            primaryColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).colorScheme.background,
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
                      text: "This should be a response to \n${message.text}",
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
                animate: false,
                bottomWidget: Row(
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
              return AnimatedTextMessage(
                message: msg,
                animate: false,
              );
            }
          },
        ),
      );
}
