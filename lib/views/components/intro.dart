import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_hero/local_hero.dart';

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
    return Center(
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
    );
  }
}
