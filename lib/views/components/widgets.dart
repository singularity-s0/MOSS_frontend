import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:provider/provider.dart';

class ShareInfoConsentWidget extends StatefulWidget {
  const ShareInfoConsentWidget({super.key});

  @override
  State<ShareInfoConsentWidget> createState() => _ShareInfoConsentWidgetState();
}

class _ShareInfoConsentWidgetState extends State<ShareInfoConsentWidget> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AccountProvider>(context).user!;
    return Row(
      children: [
        Checkbox(
          value: user.share_consent,
          onChanged: (value) async {
            try {
              await Repository.getInstance().setShareInfoConsent(value!);
              setState(() {
                user.share_consent = value;
              });
            } catch (e) {
              await showAlert(
                  context, parseError(e), AppLocalizations.of(context)!.error);
            }
          },
        ),
        Expanded(
          child: Text.rich(TextSpan(children: [
            TextSpan(
              text: AppLocalizations.of(context)!.share_consent_msg,
            ),
            const TextSpan(text: " "),
            TextSpan(
                text: AppLocalizations.of(context)!.join_user_group,
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                    decorationColor: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final uri = Uri.base;
                    showImageAlert(context, null,
                        AppLocalizations.of(context)!.join_user_group,
                        imageUrl:
                            "${uri.scheme}://${uri.host}:${uri.port}/static/user_group.png");
                  }),
          ])),
        ),
      ],
    );
  }
}
