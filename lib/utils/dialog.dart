import 'package:flutter/material.dart';

Future<T> showLoadingDialogUntilFutureCompletes<T>(
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
  try {
    final T ret = await future;
    if (dcontext == null) {
      return ret; // FIXME: this is a hack, does not guarnatee that the dialog is shown
    }
    Navigator.of(dcontext!).pop();
    return ret;
  } catch (e) {
    Navigator.of(dcontext!).pop();
    rethrow;
  }
}
