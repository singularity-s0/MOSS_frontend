import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_hero/local_hero.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/utils/syntax_highlight.dart';

class MossIntroWidget extends StatelessWidget {
  final Object heroTag;

  const MossIntroWidget({super.key, required this.heroTag});

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
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 600),
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
                    const Spacer(flex: 2),
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
                              buildBanner(context, "欢迎使用YOCSEF大模型", "在下方输入你的问题",
                                  Icons.chat),
                              // buildBanner(
                              //     context,
                              //     AppLocalizations.of(context)!.moss_intro_2a,
                              //     AppLocalizations.of(context)!.moss_intro_2b,
                              //     Icons.edit),
                              // buildBanner(
                              //     context,
                              //     AppLocalizations.of(context)!.moss_intro_3a,
                              //     AppLocalizations.of(context)!.moss_intro_3b,
                              //     Icons.help)
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
        ),
      ),
    );
  }
}

class MossOptionsWidget extends StatelessWidget {
  const MossOptionsWidget({super.key});

  static const colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      final modelCfg = Repository.getInstance().repositoryConfig!.model_config;
      final currentModel = modelCfg.firstWhere((element) =>
          element.id == AccountProvider.getInstance().user!.model_id);
      final availablePlugins = currentModel.default_plugin_config.keys
          .where((element) => currentModel.default_plugin_config[element]!)
          .toList();
      final pluginCfg = AccountProvider.getInstance().user!.plugin_config;
      return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(alignment: WrapAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: LocalHero(
                tag: "mossoptions1",
                child: SizedBox(
                  width: 225,
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
                          child: DropdownButton<int>(
                            isDense: true,
                            value: AccountProvider.getInstance().user!.model_id,
                            items: modelCfg
                                .map((e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(e.description),
                                    ))
                                .toList(),
                            onChanged: (value) async {
                              try {
                                AccountProvider.getInstance().user?.model_id =
                                    (await Repository.getInstance()
                                            .setModelConfig(value!))
                                        .model_id;
                                setState(() {});
                              } catch (e) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: LocalHero(
                tag: "mossoptions2",
                child: SizedBox(
                  width: 225,
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: pluginCfg.values
                                                .contains(true)
                                            ? pluginCfg.keys
                                                    .where((element) =>
                                                        pluginCfg[element] ==
                                                        true)
                                                    .map<Widget>((e) => Icon(
                                                        pluginToIcon[e],
                                                        size: 16,
                                                        color: colors[
                                                            e.hashCode %
                                                                colors.length]))
                                                    .toList() +
                                                [
                                                  const SizedBox(width: 8),
                                                  Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .enabled,
                                                      textScaleFactor: 0.9)
                                                ]
                                            : [
                                                Text(AppLocalizations.of(
                                                        context)!
                                                    .none)
                                              ],
                                      ))
                                ] +
                                availablePlugins.map((e) {
                                  return DropdownMenuItem(
                                      value: e,
                                      child: IgnorePointer(
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(pluginToIcon[e],
                                                      size: 16,
                                                      color: colors[e.hashCode %
                                                          colors.length]),
                                                  const SizedBox(width: 8),
                                                  Text(e, textScaleFactor: 0.9),
                                                ],
                                              ),
                                              Checkbox(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  value: AccountProvider
                                                          .getInstance()
                                                      .user!
                                                      .plugin_config[e],
                                                  onChanged: (value) {}),
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
                                AccountProvider.getInstance()
                                        .user
                                        ?.plugin_config =
                                    (await Repository.getInstance()
                                            .setPluginConfig(
                                                AccountProvider.getInstance()
                                                    .user!
                                                    .plugin_config))
                                        .plugin_config;
                                setState(() {});
                              } catch (e) {
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
