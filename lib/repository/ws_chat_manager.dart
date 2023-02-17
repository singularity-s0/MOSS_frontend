import 'dart:convert';

import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketChatManager {
  final int topicId;
  final JWToken token;
  late final WebSocketChannel channel;

  final void Function(String text)? onReceive;
  final void Function()? onDone;
  final void Function(Object error)? onError;
  final void Function(ChatRecord record)? onAddRecord;

  WebSocketChatManager(this.topicId, this.token,
      {this.onReceive, this.onDone, this.onError, this.onAddRecord}) {
    channel = WebSocketChannel.connect(Uri.parse(
        "${Repository.wsBaseUrl}/chats/$topicId/records?jwt=${token.access}"));
    channel.stream.listen((message) {
      try {
        WSInferResponse response =
            WSInferResponse.fromJson(json.decode(message));
        print(response.toJson());
        if (response.status == 1) {
          onReceive?.call(response.output);
        } else if (response.status == 0) {
          onDone?.call();
        } else if (response.status < 0) {
          onError
              ?.call(Exception("${response.status_code}: ${response.output}"));
        }
      } catch (e) {
        onError?.call(e);
      }
    });
  }

  void dispose() {
    channel.sink.close();
  }

  void sendMessage(String message) async {
    // channel.sink.add(json.encode({
    //   "request": message,
    // }));
    onReceive?.call("abc");
    await Future.delayed(const Duration(seconds: 1));
    onReceive?.call("def");
    await Future.delayed(const Duration(seconds: 1));
    onReceive?.call("def");
    await Future.delayed(const Duration(seconds: 1));
    onReceive?.call("def");
    await Future.delayed(const Duration(seconds: 1));
    onDone?.call();
  }
}
