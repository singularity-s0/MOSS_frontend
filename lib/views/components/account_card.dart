import 'dart:math';

import 'package:flutter/material.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({super.key});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  void initState() {
    super.initState();
  }

  String usernameSelector(BuildContext context, AccountProvider provider) {
    if (provider.user == null) {
      return "";
    }
    // if (provider.user!.nickname.isNotEmpty == true) {
    //   return provider.user!.nickname;
    // }
    if (provider.user!.phone.isNotEmpty == true) {
      return provider.user!.phone;
    }
    return provider.user!.email;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AccountProvider, String>(
      selector: usernameSelector,
      builder: (context, value, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  value.substringOrNone(0, 2).toUpperCase(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            Text(value),
            const Spacer(),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(AppLocalizations.of(context)!.sign_out),
                  onTap: () async {
                    await Repository.getInstance().logout();
                    if (context.mounted) {
                      while (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

extension on String {
  String substringOrNone(int start, [int? end]) {
    if (length < start) {
      return "";
    }
    end = min(end ?? length, length);
    return substring(start, end);
  }
}
