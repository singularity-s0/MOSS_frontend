import 'package:flutter/material.dart';
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
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = true;
  Object? error;

  bool _isEditing = false;

  void selectTopic(ChatThread t) {
    var parent = context.findAncestorWidgetOfExactType<ChatPage>();
    assert(parent != null, "A History Page must be a child of a Chat Page");
    parent!.currentTopic.value = t;
    widget.onTopicSelected?.call(t);
  }

  Future<void> refresh() async {
    final provider = Provider.of<AccountProvider>(context, listen: false);
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

  Future<void> addNewTopic(BuildContext context) async {
    final provider = Provider.of<AccountProvider>(context, listen: false);
    try {
      final thread = await Repository.getInstance().newChatThread();
      provider.user!.chats!.add(thread!);
      selectTopic(thread);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(parseError(e), maxLines: 3)));
      }
    }
  }

  void init() async {
    final provider = Provider.of<AccountProvider>(context, listen: false);
    await refresh();
    if (provider.user!.chats!.isNotEmpty) {
      selectTopic(provider.user!.chats!.first);
    } else {
      addNewTopic(context);
    }
  }

  @override
  void initState() {
    super.initState();
    init();
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
                addNewTopic(context);
              });
            } else if (i == listItemCount - 1 && error != null) {
              return ErrorRetryWidget(error: error, onRetry: refresh);
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
                  selectTopic(thread);
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
                                  selectTopic(provider.user!.chats!.first);
                                }
                              }
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(parseError(e), maxLines: 3)));
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
