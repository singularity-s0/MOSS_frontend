import 'dart:math';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/views/components/animated_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/views/components/chat_ui/flutter_chat_ui.dart';
import 'package:openchat_frontend/views/components/typing_indicator.dart';
import 'package:openchat_frontend/views/history_page.dart';

const user = types.User(id: 'user');
const reply = types.User(id: 'moss');

const kTabletMasterContainerWidth = 370.0;
const kTabletSingleContainerWidth = 480.0;

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= 768.0;
}

class ChatPage extends StatelessWidget {
  // The state of this page records the "Topic" that the user is currently in
  // Children can use context.findAncestorStateOfType<ChatPageState>() to read and change this
  final ValueNotifier<ChatThread?> currentTopic =
      ValueNotifier<ChatThread?>(null);
  ChatPage({super.key});

  // Mobile UI
  Widget buildMobile(BuildContext context) => HistoryPage(
        onTopicSelected: (topicId) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: ((context) => ChatView(topic: topicId))));
        },
      );

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
          ScaffoldMessenger(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width -
                  kTabletMasterContainerWidth,
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
                          builder: (context, value, child) => value == null
                              ? const SizedBox()
                              : ChatView(topic: value)),
                    ),
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
  final ChatThread topic;
  const ChatView({super.key, required this.topic});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late List<types.Message> _messages;
  late List<ChatRecord> records;

  bool lateInitDone = false;
  void lateInit() {
    lateInitDone = true;
    _messages = [
      types.SystemMessage(
        text: AppLocalizations.of(context)!.aigc_warning_message,
        id: "ai-alert",
      ),
    ];
    _getRecords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!lateInitDone) {
      lateInit();
    }
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic.id != widget.topic.id) {
      lateInit();
    }
  }

  Future<void> _getRecords() async {
    try {
      records = (widget.topic.records ??
          await Repository.getInstance().getChatRecords(widget.topic.id))!;
      setState(() {
        for (final record in records.reversed) {
          _messages.add(types.TextMessage(
            id: '${record.id}r',
            text: record.response,
            author: reply,
            metadata: {'animatedIndex': 0}, // DO NOT mark this as constant
          ));
          _messages.add(types.TextMessage(
            id: record.id.toString(),
            text: record.request,
            author: user,
            metadata: {'animatedIndex': 0}, // DO NOT mark this as constant
          ));
        }
      });
    } catch (e) {
      setState(() {
        _messages.add(types.SystemMessage(
          text: parseError(e),
          id: "ai-error${_messages.length}",
        ));
      });
    }
  }

  bool get isWaitingForResponse => _messages.first.author.id == user.id;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/logo.png', scale: 6.5),
          surfaceTintColor: Colors.transparent,
        ),
        body: Chat(
          messages: _messages,
          user: user,
          showUserAvatars: false,
          inputOptions: const InputOptions(
              inputClearMode: InputClearMode.never,
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
          onSendPressed:
              (types.PartialText message, VoidCallback clearInput) async {
            if (isWaitingForResponse) return;
            clearInput();
            setState(() {
              _messages.insert(
                  0,
                  types.TextMessage(
                      author: user,
                      text: message.text,
                      metadata: {'animatedIndex': 0},
                      id: _messages.length.toString(),
                      type: types.MessageType.text));
            });
            try {
              final response = (await Repository.getInstance()
                  .chatSendMessage(widget.topic.id, message.text))!;
              records.add(response);
              setState(() {
                _messages.insert(
                    0,
                    types.TextMessage(
                        author: reply,
                        text: response.response,
                        metadata: {'animatedIndex': 0},
                        id: _messages.length.toString(),
                        type: types.MessageType.text));
              });
            } catch (e) {
              setState(() {
                _messages.insert(
                    0,
                    types.SystemMessage(
                      text: parseError(e),
                      id: "ai-error${_messages.length}",
                    ));
              });
            }
          },
          listBottomWidget: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
            child: (_messages.first.author.id != user.id &&
                    _messages.first.author.id != reply.id)
                ? const SizedBox(height: 40)
                : AnimatedCrossFade(
                    crossFadeState: isWaitingForResponse
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
                            onPressed: () async {
                              setState(() {
                                _messages.removeAt(0);
                                records.removeAt(0);
                              });
                              try {
                                final response = (await Repository.getInstance()
                                    .chatRegenerateLast(widget.topic.id))!;
                                records.add(response);
                                setState(() {
                                  _messages.insert(
                                      0,
                                      types.TextMessage(
                                          author: reply,
                                          text: response.response,
                                          metadata: {'animatedIndex': 0},
                                          id: _messages.length.toString(),
                                          type: types.MessageType.text));
                                });
                              } catch (e) {
                                setState(() {
                                  _messages.insert(
                                      0,
                                      types.SystemMessage(
                                        text: parseError(e),
                                        id: "ai-error${_messages.length}",
                                      ));
                                });
                              }
                            }),
                        IconButton(
                          icon: Icon(Icons.thumb_up,
                              size: 16,
                              color: records.lastOrNull?.like_data == 1
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .buttonTheme
                                      .colorScheme
                                      ?.onSurface
                                      .withAlpha(130)),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            if (records.isEmpty) return;
                            int newLike = 1;
                            if (records.last.like_data == newLike) {
                              newLike = 0;
                            }
                            try {
                              await Repository.getInstance()
                                  .modifyRecord(records.last.id, newLike);
                              setState(() {
                                records.last.like_data = newLike;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(parseError(e))));
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.thumb_down,
                              size: 16,
                              color: records.lastOrNull?.like_data == -1
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .buttonTheme
                                      .colorScheme
                                      ?.onSurface
                                      .withAlpha(130)),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            if (records.isEmpty) return;
                            int newLike = -1;
                            if (records.last.like_data == newLike) {
                              newLike = 0;
                            }
                            try {
                              await Repository.getInstance()
                                  .modifyRecord(records.last.id, newLike);
                              setState(() {
                                records.last.like_data = newLike;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(parseError(e))));
                            }
                          },
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

extension ExtList<T> on List<T> {
  T? get lastOrNull => isNotEmpty ? last : null;
}
