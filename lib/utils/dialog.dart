import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openchat_frontend/model/user.dart';

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

showAlert(BuildContext context, String message, String title) {
  return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            scrollable: true,
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                  child: Text(AppLocalizations.of(context)!.ok),
                  onPressed: () => Navigator.pop(context)),
            ],
          ));
}

String parseError(Object? error) {
  if (error is String) {
    return error;
  } else if (error is DioError) {
    if (error.response != null) {
      ErrorMessage? em =
          ErrorMessage.fromJson(error.response!.data as Map<String, dynamic>);
      return "Code ${error.response!.statusCode}: ${em.message}";
    } else {
      return error.message;
    }
  } else if (error is Exception) {
    return error.toString();
  } else {
    return error.toString();
  }
}

String parseDateTime(DateTime? date) {
  if (date == null) {
    return "";
  }
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
}

class ErrorRetryWidget extends StatelessWidget {
  final Object? error;
  final void Function()? onRetry;
  const ErrorRetryWidget({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Error\n${parseError(error)}",
                    maxLines: 5, textAlign: TextAlign.center),
                TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.try_again))
              ],
            )),
      );
}
