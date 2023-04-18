// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatThread {
  int count;
  String name;
  String created_at;
  String updated_at;
  final int id;
  final int user_id;
  List<ChatRecord>? records;

  factory ChatThread.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadFromJson(json);

  Map<String, dynamic> toJson() => _$ChatThreadToJson(this);

  ChatThread(
      {required this.count,
      required this.name,
      required this.created_at,
      required this.updated_at,
      required this.id,
      required this.user_id,
      required this.records});
}

@JsonSerializable()
class ChatRecord {
  final int chat_id;
  final int id;
  String? feedback;
  int like_data;
  String created_at;
  String request;
  String response;
  List<dynamic>? extra_data;
  List<dynamic>? processed_extra_data;

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
      required this.response,
      this.extra_data,
      this.processed_extra_data});
}

@JsonSerializable()
class ModelConfig {
  final int id;
  final String description;
  final Map<String, bool> default_plugin_config;

  ModelConfig(this.id, this.description, this.default_plugin_config);

  factory ModelConfig.fromJson(Map<String, dynamic> json) =>
      _$ModelConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ModelConfigToJson(this);
}

@JsonSerializable()
class WSInferResponse {
  final int? status;
  final int? status_code;
  final String? uuid;
  final int? offset;
  final String? output;
  final String? type;
  final String? stage;

  WSInferResponse(this.status, this.status_code, this.uuid, this.offset,
      this.output, this.type, this.stage);

  factory WSInferResponse.fromJson(Map<String, dynamic> json) =>
      _$WSInferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WSInferResponseToJson(this);
}
