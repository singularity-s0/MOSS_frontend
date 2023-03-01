import 'dart:math';

import 'package:flutter/material.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:provider/provider.dart';

class UserInfo {
  final String username;
  final bool isAdmin;
  final bool disableSensitiveCheck;

  UserInfo(this.username, this.isAdmin, this.disableSensitiveCheck);
}

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
    String username;
    if (provider.user == null) {
      username = "";
    } else if (provider.user!.phone.isNotEmpty == true) {
      username = provider.user!.phone;
    } else {
      username = provider.user!.email;
    }
    return username;
  }

  Future<void> signout(BuildContext context) async {
    await Repository.getInstance().logout();
    if (context.mounted) {
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> toggleSensitiveCheck(
      void Function(void Function()) setState) async {
    await Repository.getInstance().setDisableSensitiveCheck(
        !(AccountProvider.getInstance().user!.disable_sensitive_check ??
            false));
    setState(() {
      AccountProvider.getInstance().user!.disable_sensitive_check =
          !(AccountProvider.getInstance().user!.disable_sensitive_check ??
              false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AccountProvider, String>(
      selector: usernameSelector,
      builder: (context, value, child) {
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
          StatefulBuilder(builder: (context, setState) {
            return PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (option) async {
                try {
                  switch (option) {
                    case 'sensitive_check':
                      await toggleSensitiveCheck(setState);
                      break;
                    case 'sign_out':
                      await signout(context);
                      break;
                  }
                } catch (e) {
                  await showAlert(context, parseError(e),
                      AppLocalizations.of(context)!.error);
                }
              },
              itemBuilder: (context) => [
                if ((AccountProvider.getInstance().user!.is_admin ??
                    false)) ...[
                  // Admin options
                  PopupMenuItem(
                    value: 'sensitive_check',
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.sensitive_check),
                        const Spacer(),
                        Checkbox(
                          value: !(AccountProvider.getInstance()
                                  .user!
                                  .disable_sensitive_check ??
                              false),
                          onChanged: (newValue) {
                            toggleSensitiveCheck(setState);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                PopupMenuItem(
                  value: 'sign_out',
                  child: Text(AppLocalizations.of(context)!.sign_out),
                ),
              ],
            );
          }),
        ]);
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
