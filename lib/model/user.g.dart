// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JWToken _$JWTokenFromJson(Map<String, dynamic> json) => JWToken(
      json['access'] as String,
      json['refresh'] as String,
    );

Map<String, dynamic> _$JWTokenToJson(JWToken instance) => <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
    };

ErrorMessage _$ErrorMessageFromJson(Map<String, dynamic> json) => ErrorMessage(
      data: json['data'] as String?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ErrorMessageToJson(ErrorMessage instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      email: json['email'] as String,
      id: json['id'] as int,
      joined_time: json['joined_time'] as String,
      last_login: json['last_login'] as String,
      nickname: json['nickname'] as String,
      phone: json['phone'] as String,
      chats: (json['chats'] as List<dynamic>?)
          ?.map((e) => ChatThread.fromJson(e as Map<String, dynamic>))
          .toList(),
      share_consent: json['share_consent'] as bool,
    )
      ..is_admin = json['is_admin'] as bool?
      ..disable_sensitive_check = json['disable_sensitive_check'] as bool?;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'email': instance.email,
      'id': instance.id,
      'joined_time': instance.joined_time,
      'last_login': instance.last_login,
      'nickname': instance.nickname,
      'phone': instance.phone,
      'share_consent': instance.share_consent,
      'is_admin': instance.is_admin,
      'disable_sensitive_check': instance.disable_sensitive_check,
      'chats': instance.chats,
    };
