import 'package:flutter/material.dart';
import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/views/components/account_card.dart';

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
  List<ChatThread> data = [];

  int get listItemCount =>
      (1 + ((isLoading || error != null) ? 1 : 0) + data.length);

  void selectTopic(ChatThread t) {
    var parent = context.findAncestorWidgetOfExactType<ChatPage>();
    assert(parent != null, "A History Page must be a child of a Chat Page");
    parent!.currentTopic.value = t;
    widget.onTopicSelected?.call(t);
  }

  Future<void> refresh() async {
    isLoading = true;
    try {
      final t = await Repository.getInstance().getChatThreads();
      data = t ?? [];
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
    try {
      final thread = await Repository.getInstance().newChatThread();
      data.add(thread!);
      selectTopic(thread);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(parseError(e), maxLines: 3)));
      }
    }
  }

  void init() async {
    await refresh();
    if (data.isNotEmpty) {
      selectTopic(data.first);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.topics),
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
              ChatThread thread = data[i - 1];
              return Dismissible(
                key: Key(thread.id.toString()),
                onDismissed: (direction) async {
                  try {
                    await Repository.getInstance().deleteChatThread(thread.id);
                    setState(() {
                      data.remove(thread);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(parseError(e), maxLines: 3)));
                  }
                },
                child: ListTile(
                    title: Text("Topic ${thread.id}"),
                    subtitle: Text(parseDateTime(
                        DateTime.tryParse(thread.updated_at)?.toLocal())),
                    selected: widget.selectedTopic?.id == thread.id,
                    onTap: () {
                      selectTopic(thread);
                    }),
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
