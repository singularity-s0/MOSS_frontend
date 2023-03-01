// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:openchat_frontend/model/chat.dart';

part 'user.g.dart';

@JsonSerializable()
class JWToken {
  final String access;
  final String refresh;
  JWToken(this.access, this.refresh);

  factory JWToken.fromJson(Map<String, dynamic> json) =>
      _$JWTokenFromJson(json);

  Map<String, dynamic> toJson() => _$JWTokenToJson(this);
}

@JsonSerializable()
class ErrorMessage {
  String? data;
  String message;

  factory ErrorMessage.fromJson(Map<String, dynamic> json) =>
      _$ErrorMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorMessageToJson(this);

  ErrorMessage({required this.data, required this.message});
}

@JsonSerializable()
class User {
  String email;
  final int id;
  String joined_time;
  String last_login;
  String nickname;
  String phone;
  bool share_consent;
  bool? is_admin;
  bool? disable_sensitive_check;
  List<ChatThread>? chats;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User(
      {required this.email,
      required this.id,
      required this.joined_time,
      required this.last_login,
      required this.nickname,
      required this.phone,
      required this.chats,
      required this.share_consent});
}
