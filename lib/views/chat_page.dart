import 'dart:math';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import 'package:openchat_frontend/views/components/animated_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/views/components/chat_ui/chat_theme.dart';
import 'package:openchat_frontend/views/components/chat_ui/flutter_chat_ui.dart';
import 'package:openchat_frontend/views/components/typing_indicator.dart';
import 'package:openchat_frontend/views/history_page.dart';

import 'components/chat_ui/widgets/chat.dart';

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
        mainAxisAlignment: MainAxisAlignment.center,
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
            child: SizedBox.expand(
              child: Card(
                margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                color: Theme.of(context).colorScheme.background,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: SizedBox(
                    width: min(
                        MediaQuery.of(context).size.height,
                        MediaQuery.of(context).size.width -
                            kTabletMasterContainerWidth),
                    child: ValueListenableBuilder(
                        valueListenable: currentTopic,
                        builder: (context, value, child) =>
                            ChatView(topicId: value)),
                  ),
                ),
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
  late List<types.Message> _messages;

  bool lateInitDone = false;
  void lateInit() {
    lateInitDone = true;
    _messages = [
      types.SystemMessage(
        text: AppLocalizations.of(context)!.aigc_warning_message,
        id: "ai-alert",
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!lateInitDone) {
      lateInit();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/logo.png', scale: 6.5),
        ),
        body: Chat(
          messages: _messages,
          user: user,
          showUserAvatars: false,
          inputOptions: const InputOptions(
              sendButtonVisibilityMode: SendButtonVisibilityMode.always),
          theme: DefaultChatTheme(
            primaryColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).colorScheme.surface,
            inputBackgroundColor: Theme.of(context).colorScheme.secondary,
            inputTextCursorColor: Theme.of(context).colorScheme.onSecondary,
            inputTextColor: Theme.of(context).colorScheme.onSecondary,
            inputBorderRadius: const BorderRadius.all(Radius.circular(8)),
            inputMargin: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          ),
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
          listBottomWidget: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
            child: (_messages.first.author.id != user.id &&
                    _messages.first.author.id != reply.id)
                ? const SizedBox(height: 40)
                : AnimatedCrossFade(
                    crossFadeState: _messages.first.author.id == user.id
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                    firstChild: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [TypingIndicator()]),
                    secondChild: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label:
                                Text(AppLocalizations.of(context)!.regenerate),
                            onPressed: () {}),
                        IconButton(
                          icon: Icon(Icons.thumb_up,
                              size: 16,
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme
                                  ?.onSurface
                                  .withAlpha(130)),
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.thumb_down,
                              size: 16,
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme
                                  ?.onSurface
                                  .withAlpha(130)),
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
          ),
          textMessageBuilder: (msg,
              {required messageWidth, required showName}) {
            return AnimatedTextMessage(
              message: msg,
              animate: false,
            );
          },
        ),
      );
}
