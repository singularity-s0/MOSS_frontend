import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_hero/local_hero.dart';

class MossIntroWidget extends StatelessWidget {
  final Object heroTag;

  const MossIntroWidget({Key? key, required this.heroTag}) : super(key: key);

  Widget buildBanner(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      child: ListTile(
        leading: Icon(icon),
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
            IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildBanner("Chat with MOSS in English",
                      "MOSS is learning Chinese...", Icons.chat),
                  buildBanner("Improve Writing and Coding",
                      "with the aid of MOSS", Icons.edit),
                  buildBanner("Help AI Research", "by rating responses of MOSS",
                      Icons.help)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
