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
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(parseError(e), maxLines: 3)));
              }
            },
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth - 48),
            child: Text(AppLocalizations.of(context)!.share_consent_msg,
                softWrap: true),
          ),
        ],
      ),
    );
  }
}
