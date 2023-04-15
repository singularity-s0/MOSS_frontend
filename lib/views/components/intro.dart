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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
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
                      child: LocalHero(
                          tag: heroTag,
                          child: Image.asset("assets/images/logo.webp")),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                const MossOptionsWidget(),
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
    final provider = AccountProvider.getInstance();
    try {
      if (provider.user!.chats == null) {
        final t = (await Repository.getInstance().getChatThreads())!;
        provider.user!.chats = t;
      }
      await HistoryPageState.addNewTopic(null);
    } catch (e) {
      if (context.mounted) {
        showAlert(context, parseError(e), AppLocalizations.of(context)!.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(); //MossIntroWidget(heroTag: widget.heroTag);
  }
}

class MossOptionsWidget extends StatelessWidget {
  const MossOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(alignment: WrapAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: LocalHero(
                tag: "mossoptions1",
                child: SizedBox(
                  width: 210,
                  child: Material(
                    child: DropdownButtonHideUnderline(
                      child: IntrinsicHeight(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.model,
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: DropdownButton(
                            isDense: true,
                            value: 0,
                            items: [
                              DropdownMenuItem(child: Text("16B"), value: 0),
                              DropdownMenuItem(child: Text("100B"), value: 1),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: LocalHero(
                tag: "mossoptions2",
                child: SizedBox(
                  width: 210,
                  child: Material(
                    child: DropdownButtonHideUnderline(
                      child: IntrinsicHeight(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.plugins,
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: DropdownButton(
                            value: "",
                            isDense: true,
                            items: [
                                  DropdownMenuItem(
                                      value: "",
                                      child: Text(AppLocalizations.of(context)!
                                          .i_enabled(
                                              AccountProvider.getInstance()
                                                  .user!
                                                  .plugin_config
                                                  .values
                                                  .where((element) => element)
                                                  .length)))
                                ] +
                                AccountProvider.getInstance()
                                    .user!
                                    .plugin_config
                                    .keys
                                    .map((e) {
                                  return DropdownMenuItem(
                                      value: e,
                                      child: IgnorePointer(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(e),
                                              Checkbox(
                                                  value: AccountProvider
                                                          .getInstance()
                                                      .user!
                                                      .plugin_config[e],
                                                  onChanged: (value) {})
                                            ]),
                                      ));
                                }).toList(),
                            onChanged: (value) async {
                              if (value == "") {
                                return;
                              }
                              AccountProvider.getInstance()
                                      .user!
                                      .plugin_config[value!] =
                                  !AccountProvider.getInstance()
                                      .user!
                                      .plugin_config[value]!;
                              try {
                                Repository.getInstance().setPluginConfig(
                                    AccountProvider.getInstance()
                                        .user!
                                        .plugin_config);
                                setState(() {});
                              } catch (e) {
                                AccountProvider.getInstance()
                                        .user!
                                        .plugin_config[value!] =
                                    !AccountProvider.getInstance()
                                        .user!
                                        .plugin_config[value]!;
                                await showAlert(context, parseError(e),
                                    AppLocalizations.of(context)!.error);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]));
    });
  }
}
