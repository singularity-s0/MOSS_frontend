import 'dart:convert';

import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketChatManager {
  final int topicId;
  final JWToken token;
  WebSocketChannel? channel;

  final void Function(String text)? onReceive;
  final void Function()? onDone;
  final void Function(Object error)? onError;
  final void Function(ChatRecord record)? onAddRecord;

  bool expectRecord = false;

  WebSocketChatManager(this.topicId, this.token,
      {this.onReceive, this.onDone, this.onError, this.onAddRecord});

  void dispose() {
    channel?.sink.close();
  }

  void sendMessage(String message) async {
    try {
      channel = WebSocketChannel.connect(Uri.parse(Uri.encodeFull(
          "${Repository.wsBaseUrl}/chats/$topicId/records?jwt=${token.access}")));
      channel!.stream.listen((message) {
        try {
          if (expectRecord) {
            ChatRecord record = ChatRecord.fromJson(json.decode(message));
            onAddRecord?.call(record);
            expectRecord = false;
            try {
              channel!.sink.close();
            } catch (_) {}
            channel = null;
          } else {
            WSInferResponse response =
                WSInferResponse.fromJson(json.decode(message));
            if (response.status == 1) {
              onReceive?.call(response.output!);
            } else if (response.status == 0) {
              onDone?.call();
              expectRecord = true;
            } else if ((response.status ?? -99) < 0) {
              if (response.status_code == null) {
                if (response.output == null) {
                  onError?.call("Unknown error");
                } else {
                  onError?.call(response.output!);
                }
              } else {
                onError?.call("${response.status_code}: ${response.output}");
              }
              try {
                channel!.sink.close();
              } catch (_) {}
              channel = null;
            }
          }
        } catch (e) {
          onError?.call(e);
        }
      });
      await channel!.ready;
      channel!.sink.add(json.encode({
        "request": message,
      }));
    } catch (e) {
      onError?.call(e);
    }
  }

  void regenerate() async {
    try {
      channel = WebSocketChannel.connect(Uri.parse(Uri.encodeFull(
          "${Repository.wsBaseUrl}/chats/$topicId/regenerate?jwt=${token.access}")));
      channel!.stream.listen((message) {
        try {
          if (expectRecord) {
            ChatRecord record = ChatRecord.fromJson(json.decode(message));
            onAddRecord?.call(record);
            expectRecord = false;
            try {
              channel!.sink.close();
            } catch (_) {}
            channel = null;
          } else {
            WSInferResponse response =
                WSInferResponse.fromJson(json.decode(message));
            if (response.status == 1) {
              onReceive?.call(response.output!);
            } else if (response.status == 0) {
              onDone?.call();
              expectRecord = true;
            } else if ((response.status ?? -99) < 0) {
              if (response.status_code == null) {
                if (response.output == null) {
                  onError?.call("Unknown error");
                } else {
                  onError?.call(response.output!);
                }
              } else {
                onError?.call("${response.status_code}: ${response.output}");
              }
              try {
                channel!.sink.close();
              } catch (_) {}
              channel = null;
            }
          }
        } catch (e) {
          onError?.call(e);
        }
      });
      await channel!.ready;
    } catch (e) {
      onError?.call(e);
    }
  }
}
