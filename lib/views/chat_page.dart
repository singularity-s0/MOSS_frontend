import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import 'package:openchat_frontend/main.dart';
import 'package:openchat_frontend/repository/ws_chat_manager.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:local_hero/local_hero.dart';
import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/views/components/animated_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/views/components/chat_ui/flutter_chat_ui.dart';
import 'package:openchat_frontend/views/components/intro.dart';
import 'package:openchat_frontend/views/components/typing_indicator.dart';
import 'package:openchat_frontend/views/components/widgets.dart';
import 'package:openchat_frontend/views/history_page.dart';
import 'package:provider/provider.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const user = types.User(id: 'user');
const reply = types.User(id: 'moss');

const kTabletMasterContainerWidth = 370.0;
const kTabletSingleContainerWidth = 480.0;

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= 768.0;
}

class ChatView extends StatefulWidget {
  final ChatThread topic;
  final bool showMenu;
  const ChatView({super.key, required this.topic, this.showMenu = false});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final GlobalKey<ChatState> _chatKey = GlobalKey();
  final List<types.Message> _messages = [];

  late final WebSocketChatManager chatManager;

  bool isFirstResponse = true;
  bool isStreamingResponse = false;

  bool lateInitDone = false;

  void lateInit() {
    lateInitDone = true;
    _messages.clear();
    _getRecords();
    chatManager = WebSocketChatManager(
      widget.topic.id,
      Provider.of<AccountProvider>(context).token!,
      onAddRecord: (record) {
        final provider = Provider.of<AccountProvider>(context, listen: false);
        if (widget.topic.records!.isEmpty) {
          // Handle first record: change title and add warning message
          provider.user!.chats!
              .firstWhere((element) => element.id == widget.topic.id)
              .name = record.request.substring(0, 30);
        }
        widget.topic.records!.add(record);
      },
      onDone: () {
        if (mounted) {
          setState(() {
            isStreamingResponse = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          isStreamingResponse = false;
          setState(() {
            _messages.insert(
                0,
                types.SystemMessage(
                  text: parseError(error),
                  id: "${widget.topic.id}ai-error${_messages.length}",
                ));
          });
        }
      },
      onReceive: (event) {
        if (isFirstResponse) {
          isFirstResponse = false;
          if (mounted) {
            setState(() {
              _messages.insert(
                  0,
                  types.TextMessage(
                      author: reply,
                      text: event,
                      // ignore: prefer_const_literals_to_create_immutables
                      metadata: {'animatedIndex': 0, 'currentText': event},
                      id: _messages.length.toString(),
                      type: types.MessageType.text));
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _messages.first.metadata!['currentText'] = event;
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    chatManager.dispose();
    super.dispose();
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
      widget.topic.records ??=
          await Repository.getInstance().getChatRecords(widget.topic.id);
      if (widget.topic.records!.isNotEmpty) {
        setState(() {
          _messages.insert(
              0,
              types.SystemMessage(
                text: "",
                id: "${widget.topic.id}hack",
              ));
        });
        await Future.delayed(
            const Duration(milliseconds: 100)); // A hack to let animations run
        _messages.insert(
            0,
            types.SystemMessage(
              text: AppLocalizations.of(context)!.aigc_warning_message,
              id: "${widget.topic.id}ai-alert",
            ));
      }
      for (final record in widget.topic.records!) {
        _messages.insert(
            0,
            types.TextMessage(
              id: "${widget.topic.id}-${record.id}",
              text: record.request,
              author: user,
              // ignore: prefer_const_literals_to_create_immutables
              metadata: {'animatedIndex': record.request.length},
            ));
        _messages.insert(
            0,
            types.TextMessage(
              id: "${widget.topic.id}-${record.id}r",
              text: record.response,
              author: reply,
              // ignore: prefer_const_literals_to_create_immutables
              metadata: {'animatedIndex': record.response.length},
            ));
      }
    } catch (e) {
      _messages.insert(
          0,
          types.SystemMessage(
            text: parseError(e),
            id: "${widget.topic.id}ai-error${_messages.length}",
          ));
    } finally {
      setState(() {});
    }
  }

  bool get isWaitingForResponse =>
      (_messages.firstOrNull?.author.id == user.id) || isStreamingResponse;

  bool get shouldUseLargeLogo {
    if (_messages.isNotEmpty) {
      return false;
    }
    if (widget.topic.records == null) {
      return widget.topic.name.isEmpty ||
          widget.topic.name == AppLocalizations.of(context)!.untitled_topic;
    }
    return widget.topic.records!.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: (widget.showMenu)
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (historyPageContext) => HistoryPage(
                          selectedTopic: widget.topic,
                          onTopicSelected: (p0) {
                            var parent = context
                                .findAncestorWidgetOfExactType<ChatPage>();
                            assert(parent != null,
                                "A History Page must be a child of a Chat Page");
                            parent!.currentTopic.value = p0;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ))
            : null,
        title: shouldUseLargeLogo
            ? const SizedBox()
            : LocalHero(
                tag:
                    "MossLogo${isDesktop(context) ? "Desktop" : widget.topic.id}}",
                child: Image.asset('assets/images/logo.png', scale: 6.5)),
        surfaceTintColor: Colors.transparent,
      ),
      body: Chat(
        key: _chatKey,
        messages: _messages,
        user: user,
        showUserAvatars: false,
        inputOptions: const InputOptions(
            inputClearMode: InputClearMode.never,
            sendButtonVisibilityMode: SendButtonVisibilityMode.always),
        theme: DefaultChatTheme(
          primaryColor: themeColor,
          backgroundColor: Theme.of(context).colorScheme.surface,
          inputBackgroundColor: Theme.of(context).colorScheme.secondary,
          inputTextCursorColor: Theme.of(context).colorScheme.onSecondary,
          inputTextColor: Theme.of(context).colorScheme.onSecondary,
          inputBorderRadius: const BorderRadius.all(Radius.circular(8)),
          inputMargin: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          sentMessageSelectionColor: const Color(0x7fdda0dd),
          receivedMessageSelectionColor: null,
        ),
        emptyState: shouldUseLargeLogo
            ? MossIntroWidget(
                heroTag:
                    "MossLogo${isDesktop(context) ? "Desktop" : widget.topic.id}}",
              )
            : const SizedBox(),
        customBottomWidget: const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 12, right: 12),
            child: ShareInfoConsentWidget()),
        onSendPressed:
            (types.PartialText message, VoidCallback clearInput) async {
          if (isWaitingForResponse || widget.topic.records == null) return;
          final topic = widget.topic;
          final provider = Provider.of<AccountProvider>(context, listen: false);
          clearInput();
          setState(() {
            if (topic.records!.isEmpty) {
              _messages.insert(
                  0,
                  types.SystemMessage(
                    text: AppLocalizations.of(context)!.aigc_warning_message,
                    id: "${widget.topic.id}ai-alert",
                  ));
            }
            _messages.insert(
                0,
                types.TextMessage(
                    author: user,
                    text: message.text,
                    // ignore: prefer_const_literals_to_create_immutables
                    metadata: {'animatedIndex': 0},
                    id: _messages.length.toString(),
                    type: types.MessageType.text));
          });
          try {
            isFirstResponse = true;
            isStreamingResponse = true;
            chatManager.sendMessage(message.text);
          } catch (e) {
            if (mounted) {
              setState(() {
                _messages.insert(
                    0,
                    types.SystemMessage(
                      text: parseError(e),
                      id: "ai-error${_messages.length}",
                    ));
              });
            }
          }
        },
        listBottomWidget: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
          child: (_messages.firstOrNull?.author.id != user.id &&
                  _messages.firstOrNull?.author.id != reply.id)
              ? const SizedBox(height: 40)
              : AnimatedCrossFade(
                  crossFadeState: isWaitingForResponse
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200),
                  firstChild: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [TypingIndicator()]),
                  secondChild: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton.icon(
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text(AppLocalizations.of(context)!.regenerate),
                          onPressed: () async {
                            final topic = widget.topic;
                            setState(() {
                              _messages.removeAt(0);
                              topic.records!.removeLast();
                            });
                            try {
                              final response = (await Repository.getInstance()
                                  .chatRegenerateLast(topic.id))!;
                              topic.records!.add(response);
                              if (mounted) {
                                setState(() {
                                  _messages.insert(
                                      0,
                                      types.TextMessage(
                                          author: reply,
                                          text: response.response,
                                          // ignore: prefer_const_literals_to_create_immutables
                                          metadata: {'animatedIndex': 0},
                                          id: _messages.length.toString(),
                                          type: types.MessageType.text));
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _messages.insert(
                                      0,
                                      types.SystemMessage(
                                        text: parseError(e),
                                        id: "ai-error${_messages.length}",
                                      ));
                                });
                              }
                            }
                          }),
                      IconButton(
                        icon: Icon(Icons.thumb_up,
                            size: 16,
                            color:
                                widget.topic.records!.lastOrNull?.like_data == 1
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .buttonTheme
                                        .colorScheme
                                        ?.onSurface
                                        .withAlpha(130)),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (widget.topic.records?.isEmpty != false) return;
                          int newLike = 1;
                          if (widget.topic.records!.last.like_data == newLike) {
                            newLike = 0;
                          }
                          try {
                            await Repository.getInstance().modifyRecord(
                                widget.topic.records!.last.id, newLike);
                            setState(() {
                              widget.topic.records!.last.like_data = newLike;
                            });
                          } catch (e) {
                            await showAlert(context, parseError(e),
                                AppLocalizations.of(context)!.error);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.thumb_down,
                            size: 16,
                            color:
                                widget.topic.records!.lastOrNull?.like_data ==
                                        -1
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .buttonTheme
                                        .colorScheme
                                        ?.onSurface
                                        .withAlpha(130)),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (widget.topic.records?.isEmpty != false) return;
                          int newLike = -1;
                          if (widget.topic.records!.last.like_data == newLike) {
                            newLike = 0;
                          }
                          try {
                            await Repository.getInstance().modifyRecord(
                                widget.topic.records!.last.id, newLike);
                            setState(() {
                              widget.topic.records!.last.like_data = newLike;
                            });
                          } catch (e) {
                            await showAlert(context, parseError(e),
                                AppLocalizations.of(context)!.error);
                          }
                        },
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            String content = "";
                            for (final record in widget.topic.records!) {
                              content += "[User]\n${record.request}\n\n";
                              content += "[MOSS]\n${record.response}\n\n";
                            }
                            FlutterClipboard.copy(content);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .copied_to_clipboard)));
                          },
                          icon: const Icon(Icons.copy_all)),
                      IconButton(
                          onPressed: () {
                            _chatKey.currentState!
                                .takeScreenshot()
                                .then((bytes) {
                              WebImageDownloader.downloadImageFromUInt8List(
                                  uInt8List: bytes,
                                  name: "moss-${widget.topic.id}.png");
                            });
                          },
                          icon: const Icon(Icons.share)),
                    ],
                  ),
                ),
        ),
        textMessageBuilder: (msg, {required messageWidth, required showName}) {
          return AnimatedTextMessage(
              message: msg, speed: 25, animate: msg.author.id == reply.id);
        },
      ),
    );
  }
}

extension ExtList<T> on List<T> {
  T? get lastOrNull => isNotEmpty ? last : null;
  T? get firstOrNull => isNotEmpty ? first : null;
}
