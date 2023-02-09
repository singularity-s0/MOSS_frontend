import 'package:flutter/foundation.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/utils/settings_provider.dart';

class AccountProvider with ChangeNotifier {
  // Single instance class
  static final _instance = AccountProvider._();
  factory AccountProvider.getInstance() => _instance;
  AccountProvider._() {
    // Try to load token from settings.
    token = SettingsProvider.getInstance().token;
  }

  // Login info, if this is null, the user is not logged in.
  JWToken? _token;
  JWToken? get token => _token;
  set token(JWToken? value) {
    _token = value;
    notifyListeners();
  }
}
