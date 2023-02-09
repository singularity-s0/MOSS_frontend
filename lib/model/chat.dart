// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatThread {
  int count;
  String created_at;
  String updated_at;
  int id;
  int user_id;
  List<ChatRecord> records;

  factory ChatThread.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadFromJson(json);

  Map<String, dynamic> toJson() => _$ChatThreadToJson(this);

  ChatThread(
      {required this.count,
      required this.created_at,
      required this.updated_at,
      required this.id,
      required this.user_id,
      required this.records});
}

@JsonSerializable()
class ChatRecord {
  int chat_id;
  int id;
  String? feedback;
  int like_data;
  String created_at;
  String request;
  String response;

  factory ChatRecord.fromJson(Map<String, dynamic> json) =>
      _$ChatRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRecordToJson(this);

  ChatRecord(
      {required this.chat_id,
      required this.id,
      this.feedback,
      required this.like_data,
      required this.created_at,
      required this.request,
      required this.response});
}
