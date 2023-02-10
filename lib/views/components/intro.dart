import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/views/components/local_hero/local_hero.dart';

class MossIntroWidget extends StatelessWidget {
  final Object heroTag;

  const MossIntroWidget({Key? key, required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 256),
                child: LocalHero(
                    tag: heroTag, child: Image.asset("assets/images/logo.png")),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 368),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.moss_intro_1,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    AppLocalizations.of(context)!.moss_intro_2,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    AppLocalizations.of(context)!.moss_intro_3,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
