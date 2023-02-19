import 'package:flutter/material.dart';
import 'package:openchat_frontend/main.dart';
import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/views/components/account_card.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  final ChatThread? selectedTopic;
  final Function(ChatThread)? onTopicSelected;
  const HistoryPage({super.key, this.selectedTopic, this.onTopicSelected});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  bool isLoading = true;
  Object? error;

  bool _isEditing = false;

  Future<void> load() async {
    final provider = Provider.of<AccountProvider>(context, listen: false);
    if (provider.user!.chats != null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    isLoading = true;
    try {
      final t = await Repository.getInstance().getChatThreads();
      provider.user!.chats = t;
      error = null;
    } catch (e) {
      error = e;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  static void selectTopic(
      BuildContext context, ChatThread t, Function(ChatThread)? callback) {
    if (!context.mounted) return;
    if (callback != null) {
      callback(t);
    } else {
      if (context.mounted) {
        var parent = context.findAncestorStateOfType<ChatPageState>();
        assert(parent != null, "A History Page must be a child of a Chat Page");
        parent!.currentTopic.value = t;
      }
    }
  }

  static Future<void> addNewTopic(
      BuildContext context, Function(ChatThread)? callback) async {
    if (!context.mounted) return;
    final provider = Provider.of<AccountProvider>(context, listen: false);
    try {
      final thread = await Repository.getInstance().newChatThread();
      provider.user!.chats!.insert(0, thread!);
      selectTopic(context, thread, callback);
    } catch (e) {
      if (context.mounted) {
        await showAlert(
            context, parseError(e), AppLocalizations.of(context)!.error);
      }
    }
  }

  bool lateInitDone = false;
  void lateInit() async {
    lateInitDone = true;
    await load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!lateInitDone) {
      lateInit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);
    final listItemCount = (1 +
        ((isLoading || error != null) ? 1 : 0) +
        (provider.user?.chats?.length ?? 0));
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.topics),
        actions: [
          IconButton(
              onPressed: () => setState(() {
                    _isEditing = !_isEditing;
                  }),
              icon: Text(_isEditing
                  ? AppLocalizations.of(context)!.done
                  : AppLocalizations.of(context)!.edit))
        ],
      ),
      body: ListView.builder(
          itemBuilder: (context, i) {
            if (i == 0) {
              return NewTopicButton(onTap: () async {
                addNewTopic(context, widget.onTopicSelected);
              });
            } else if (i == listItemCount - 1 && error != null) {
              return ErrorRetryWidget(error: error, onRetry: load);
            } else if (i == listItemCount - 1 && isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              ChatThread thread = provider.user!.chats![i - 1];
              return ListTile(
                title: Text(thread.name.isEmpty
                    ? AppLocalizations.of(context)!.untitled_topic
                    : thread.name),
                subtitle: Text(parseDateTime(
                    DateTime.tryParse(thread.updated_at)?.toLocal())),
                selected: widget.selectedTopic?.id == thread.id,
                onTap: () {
                  selectTopic(context, thread, widget.onTopicSelected);
                },
                trailing: _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          try {
                            await Repository.getInstance()
                                .deleteChatThread(thread.id);
                            setState(() {
                              provider.user!.chats!.remove(thread);
                              if (widget.selectedTopic?.id == thread.id) {
                                if (provider.user!.chats!.isNotEmpty) {
                                  selectTopic(
                                      context,
                                      provider.user!.chats!.first,
                                      widget.onTopicSelected);
                                }
                              }
                            });
                          } catch (e) {
                            await showAlert(context, parseError(e),
                                AppLocalizations.of(context)!.error);
                          }
                        },
                      )
                    : null,
              );
            }
          },
          itemCount: listItemCount),
      bottomSheet: const AccountCard(),
    );
  }
}

class NewTopicButton extends StatelessWidget {
  final VoidCallback? onTap;
  const NewTopicButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.add),
      title: Text(AppLocalizations.of(context)!.new_topic),
    );
  }
}
