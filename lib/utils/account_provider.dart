import 'package:flutter/foundation.dart';

class JWToken {
  final String access;
  final String refresh;

  JWToken(this.access, this.refresh);
}

class AccountProvider with ChangeNotifier {
  // Single instance class
  static final _instance = AccountProvider._();
  factory AccountProvider.getInstance() => _instance;
  AccountProvider._() {
    // Initialize the account provider, e.g. load from local storage
  }

  // Login info, if this is null, the user is not logged in.
  JWToken? _token;
  JWToken? get token => _token;
  set token(JWToken? value) {
    _token = value;
    notifyListeners();
  }
}
