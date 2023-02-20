import 'package:flutter/foundation.dart';
import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/repository/repository.dart';
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
    return _user;
  }

  set user(User? value) {
    User? previous_user = _user;
    _user = value;
    if (previous_user != _user) {
      notifyListeners();
    }
  }

  Future<User> ensureUserInfo() async {
    user ??= (await Repository.getInstance().getUserInfo())!;
    return user!;
  }

  Future<void> fetchUserInfo() async {
    user = (await Repository.getInstance().getUserInfo())!;
  }
}

class TopicStateProvider with ChangeNotifier {
  // Single instance class
  static final _instance = TopicStateProvider._();
  factory TopicStateProvider.getInstance() => _instance;
  TopicStateProvider._();

  // Current chat topic
  ChatThread? _currentTopic;
  ChatThread? get currentTopic => _currentTopic;
  set currentTopic(ChatThread? value) {
    _currentTopic = value;
    notifyListeners();
  }
}
