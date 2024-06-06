import 'dart:async';
import 'dart:convert';

import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketChatManager {
  final int topicId;
  final JWToken token;
  WebSocketChannel? channel;

  static const Duration wsTimeout = Duration(seconds: 125);
  Timer? wsTimer;
  void onTimeout() async {
    onError?.call("Connection Timeout");
    try {
      await channel!.sink.close();
    } catch (_) {}
    channel = null;
  }

  final void Function(String text, int code, String? type, String? stage)?
      onReceive;
  final void Function()? onDone;
  final void Function(Object error)? onError;
  final void Function(SimpleChatRecord record)? onAddRecord;

  bool expectRecord = false;
  bool ended = false;

  WebSocketChatManager(this.topicId, this.token,
      {this.onReceive, this.onDone, this.onError, this.onAddRecord});

  void dispose() {
    channel?.sink.close();
  }

  void sendMessage(String message, List<SimpleChatRecord> records) async {
    ended = false;
    try {
      channel = WebSocketChannel.connect(
          Uri.parse(Uri.encodeFull("${Repository.wsBaseUrl}/yocsef/inference")));
      channel!.stream.listen((responseMsg) async {
        wsTimer?.cancel();
        wsTimer = Timer(wsTimeout, onTimeout);
        try {
          if (expectRecord) {
            try {
              var decoded = json.decode(responseMsg);
              decoded['request'] = message;
              SimpleChatRecord record = SimpleChatRecord.fromJson(decoded);
              onAddRecord?.call(record);
              expectRecord = false;
              wsTimer?.cancel();
              ended = true;
              try {
                await channel!.sink.close();
              } catch (_) {}
              channel = null;
            } catch (error) {
              print(error);
              onError
                  ?.call("An unexpected response was received from the server");
            }
            try {
              await channel!.sink.close();
            } catch (_) {}
            channel = null;
          } else {
            WSInferResponse response =
                WSInferResponse.fromJson(json.decode(responseMsg));
            if (response.status == 1 || response.status == 3) {
              onReceive?.call(response.output!, response.status!, response.type,
                  response.stage);
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
                await channel!.sink.close();
              } catch (_) {}
              channel = null;
            }
          }
        } catch (e) {
          onError?.call(e);
        }
      }, onDone: () async {
        ended = true;
        wsTimer?.cancel();
        onDone?.call();
        try {
          await channel!.sink.close();
        } catch (_) {}
        channel = null;
      }, onError: (e) {
        if (!ended) {
          onError?.call(e);
        }
        wsTimer?.cancel();
        ended = true;
      }, cancelOnError: true);
      await channel!.ready;
      // Set timeout
      wsTimer = Timer(wsTimeout, onTimeout);
      channel!.sink.add(json.encode({
        'records': records,
        "request": message,
      }));
    } catch (e) {
      wsTimer?.cancel();
      try {
        await channel?.sink.close();
      } catch (_) {}
      if (!ended) {
        onError?.call(e);
      }
      ended = true;
    }
  }

  void regenerate() async {
    //   ended = false;
    //   try {
    //     channel = WebSocketChannel.connect(Uri.parse(Uri.encodeFull(
    //         "${Repository.wsBaseUrl}/chats/$topicId/regenerate?jwt=${token.access}")));
    //     channel!.stream.listen((message) async {
    //       wsTimer?.cancel();
    //       wsTimer = Timer(wsTimeout, onTimeout);
    //       try {
    //         if (expectRecord) {
    //           ChatRecord record = ChatRecord.fromJson(json.decode(message));
    //           onAddRecord?.call(record);
    //           expectRecord = false;
    //           wsTimer?.cancel();
    //           ended = true;
    //           try {
    //             await channel!.sink.close();
    //           } catch (_) {}
    //           channel = null;
    //         } else {
    //           WSInferResponse response =
    //               WSInferResponse.fromJson(json.decode(message));
    //           if (response.status == 1 || response.status == 3) {
    //             onReceive?.call(response.output!, response.status!, response.type,
    //                 response.stage);
    //           } else if (response.status == 0) {
    //             onDone?.call();
    //             expectRecord = true;
    //           } else if ((response.status ?? -99) < 0) {
    //             if (response.status_code == null) {
    //               if (response.output == null) {
    //                 onError?.call("Unknown error");
    //               } else {
    //                 onError?.call(response.output!);
    //               }
    //             } else {
    //               onError?.call("${response.status_code}: ${response.output}");
    //             }
    //             try {
    //               await channel!.sink.close();
    //             } catch (_) {}
    //             channel = null;
    //           }
    //         }
    //       } catch (e) {
    //         onError?.call(e);
    //       }
    //     }, onDone: () async {
    //       ended = true;
    //       wsTimer?.cancel();
    //       onDone?.call();
    //       try {
    //         await channel!.sink.close();
    //       } catch (_) {}
    //       channel = null;
    //     }, onError: (e) {
    //       if (!ended) {
    //         onError?.call(e);
    //       }
    //       wsTimer?.cancel();
    //       ended = true;
    //     }, cancelOnError: true);
    //     await channel!.ready;
    //     // Set timeout
    //     wsTimer = Timer(wsTimeout, onTimeout);
    //   } catch (e) {
    //     wsTimer?.cancel();
    //     try {
    //       await channel?.sink.close();
    //     } catch (_) {}
    //     if (!ended) {
    //       onError?.call(e);
    //     }
    //     ended = true;
    //   }
  }
}
