import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/settings_provider.dart';

bool _isFrameReady = false;
void setFrameReady() {
  if (!_isFrameReady) {
    _isFrameReady = true;
    FlutterNativeSplash.remove();
  }
}

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
    bool isPreviousNull = _token == null;
    bool isNewNull = value == null;
    _token = value;
    if (isPreviousNull != isNewNull) {
      notifyListeners();
    }
  }

  // User info, if this is null, the user is not logged in.
  User? _user;
  User? get user {
    if (_user == null) {
      fetchUserInfo();
    }
    return _user;
  }

  set user(User? value) {
    User? previous_user = _user;
    _user = value;
    if (previous_user != _user) {
      notifyListeners();
    }
  }

  Future<void> fetchUserInfo() async {
    try {
      user = await Repository.getInstance().getUserInfo();
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }
}
