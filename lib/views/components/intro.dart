import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_hero/local_hero.dart';
import 'package:openchat_frontend/main.dart';
import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/views/history_page.dart';
import 'package:provider/provider.dart';

class MossIntroWidget extends StatelessWidget {
  final Object heroTag;

  const MossIntroWidget({Key? key, required this.heroTag}) : super(key: key);

  Widget buildBanner(
      BuildContext context, String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 6,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 256),
                      child: LocalHero(
                          tag: heroTag,
                          child: Image.asset("assets/images/logo.png")),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Flexible(
                flex: 10,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildBanner(
                            context,
                            AppLocalizations.of(context)!.moss_intro_1a,
                            AppLocalizations.of(context)!.moss_intro_1b,
                            Icons.chat),
                        buildBanner(
                            context,
                            AppLocalizations.of(context)!.moss_intro_2a,
                            AppLocalizations.of(context)!.moss_intro_2b,
                            Icons.edit),
                        buildBanner(
                            context,
                            AppLocalizations.of(context)!.moss_intro_3a,
                            AppLocalizations.of(context)!.moss_intro_3b,
                            Icons.help)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NullChatLoader extends StatefulWidget {
  final Object heroTag;
  const NullChatLoader({Key? key, required this.heroTag}) : super(key: key);

  @override
  State<NullChatLoader> createState() => _NullChatLoaderState();
}

class _NullChatLoaderState extends State<NullChatLoader> {
  bool lateInitDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!lateInitDone) {
      lateInit();
    }
  }

  void lateInit() async {
    lateInitDone = true;
    final provider = Provider.of<AccountProvider>(context, listen: false);
    if (provider.user!.chats == null) {
      final t = await Repository.getInstance().getChatThreads();
      provider.user!.chats = t;
    }
    HistoryPageState.addNewTopic(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(); //MossIntroWidget(heroTag: widget.heroTag);
  }
}
