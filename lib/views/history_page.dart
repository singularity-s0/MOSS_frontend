import 'package:flutter/material.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  final String selectedTopic;
  const HistoryPage({super.key, required this.selectedTopic});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Topics')),
      body: ListView.builder(
          itemBuilder: (context, i) {
            if (i == 0) {
              return NewTopicButton();
            } else {
              return ListTile(
                  title: Text("Topic $i"),
                  subtitle: Text('Subtitle'),
                  selected: widget.selectedTopic == 'id $i',
                  onTap: () {
                    var parent =
                        context.findAncestorStateOfType<ChatPageState>();
                    assert(parent != null,
                        "A History Page must be a child of a Chat Page");
                    parent!.setState(() {
                      parent.currentTopic.value = 'id $i';
                    });
                  });
            }
          },
          itemCount: 10),
    );
  }
}

class NewTopicButton extends StatelessWidget {
  const NewTopicButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => null,
      leading: const Icon(Icons.add),
      title: const Text("New Topic"),
    );
  }
}
