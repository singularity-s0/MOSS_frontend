// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences preferences;
  static final _instance = SettingsProvider._();
  SettingsProvider._();
  factory SettingsProvider.getInstance() => _instance;

  Future<void> init() async =>
      preferences = await SharedPreferences.getInstance();

  static const KEY_TOKEN = "token";
  JWToken? get token {
    if (preferences.containsKey(KEY_TOKEN)) {
      try {
        return JWToken.fromJson(jsonDecode(preferences.getString(KEY_TOKEN)!));
      } catch (_) {}
    }
    return null;
  }

  set token(JWToken? value) {
    if (value != null) {
      preferences.setString(KEY_TOKEN, jsonEncode(value));
    } else {
      preferences.remove(KEY_TOKEN);
    }
    // Saved token do not need listeners. They are provided by AccountProvider instead.
  }
}
