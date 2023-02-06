import 'package:flutter/material.dart';

Future<void> showLoadingDialogUntilFutureCompletes<T>(
    BuildContext context, Future<T> future) async {
  BuildContext? dcontext;
  showDialog<T>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        dcontext = context;
        return const AlertDialog(
          icon: Center(child: CircularProgressIndicator()),
        );
      });
  await future;
  if (dcontext == null)
    return; // FIXME: this is a hack, does not guarnatee that the dialog is shown
  Navigator.of(dcontext!).pop();
}
