import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:dio/dio.dart';
import 'package:openchat_frontend/utils/settings_provider.dart';
import 'package:openchat_frontend/views/login_page.dart';

class Repository {
  static final _instance = Repository._();

  factory Repository.getInstance() => _instance;

  static const String baseUrl = "https://moss.fastnlp.top/api";
  static const String wsBaseUrl = "ws://moss.jingyijun.xyz:12442/api/ws";

  static const String waitlistUrl = "https://survey.moss.fastnlp.top/s/Ntd4eG";

  final Dio dio = Dio();

  late AccountProvider provider;

  static void init(AccountProvider injectProvider) {
    Repository.getInstance().provider = injectProvider;
  }

  Repository._() {
    // Override the options set in parent class.
    dio.options = BaseOptions(
      receiveDataWhenStatusError: true,
      validateStatus: (int? status) {
        return status != null && status >= 200 && status < 300;
      },
    );

    dio.interceptors.add(JWTInterceptor(
        "$baseUrl/refresh",
        () => provider.token,
        (token) =>
            provider.token = SettingsProvider.getInstance().token = token));
  }

  Future<void> requestEmailVerifyCode(String email, String scope) async {
    await dio.get("$baseUrl/verify/email",
        queryParameters: {"email": email, "scope": scope});
  }

  Future<void> requestPhoneVerifyCode(String phone, String scope) async {
    await dio.get("$baseUrl/verify/phone",
        queryParameters: {"phone": phone, "scope": scope});
  }

  Future<JWToken?> registerWithEmailPassword(
      String email, String password, String verifyCode, String inviteCode,
      {bool resetPassword = false}) async {
    final Response<Map<String, dynamic>> response = await dio.fetch(
        RequestOptions(
            method: resetPassword ? "PUT" : "POST",
            path: "$baseUrl/register",
            data: {
          "password": password,
          "email": email,
          "verification": verifyCode,
          if (!resetPassword && inviteCode.isNotEmpty)
            "invite_code": inviteCode,
        }));
    return provider.token =
        SettingsProvider.getInstance().token = JWToken.fromJson(response.data!);
  }

  Future<JWToken?> registerWithPhonePassword(
      String phone, String password, String verifyCode, String inviteCode,
      {bool resetPassword = false}) async {
    final Response<Map<String, dynamic>> response = await dio.fetch(
        RequestOptions(
            method: resetPassword ? "PUT" : "POST",
            path: "$baseUrl/register",
            data: {
          "password": password,
          "phone": phone,
          "verification": verifyCode,
          if (!resetPassword && inviteCode.isNotEmpty)
            "invite_code": inviteCode,
        }));
    return provider.token =
        SettingsProvider.getInstance().token = JWToken.fromJson(response.data!);
  }

  Future<JWToken?> loginWithEmailPassword(String email, String password) async {
    final Response<Map<String, dynamic>> response =
        await dio.post("$baseUrl/login", data: {
      'email': email,
      'password': password,
    });
    return provider.token =
        SettingsProvider.getInstance().token = JWToken.fromJson(response.data!);
  }

  Future<JWToken?> loginWithPhonePassword(String phone, String password) async {
    final Response<Map<String, dynamic>> response =
        await dio.post("$baseUrl/login", data: {
      'phone': phone,
      'password': password,
    });
    return provider.token =
        SettingsProvider.getInstance().token = JWToken.fromJson(response.data!);
  }

  Future<void> logout() async {
    await dio.get("$baseUrl/logout", options: Options(headers: _tokenHeader));
    provider.token = SettingsProvider.getInstance().token = null;
  }

  Map<String, String> get _tokenHeader {
    assert(provider.token != null);
    return {"Authorization": "Bearer ${provider.token!.access}"};
  }

  Future<List<ChatThread>?> getChatThreads() async {
    final Response response = await dio.get("$baseUrl/chats",
        options: Options(headers: _tokenHeader));
    return (response.data! as List).map((e) => ChatThread.fromJson(e)).toList();
  }

  Future<ChatThread?> newChatThread() async {
    final Response response = await dio.post("$baseUrl/chats",
        options: Options(headers: _tokenHeader));
    return ChatThread.fromJson(response.data!);
  }

  Future<void> deleteChatThread(int id) async {
    await dio.delete("$baseUrl/chats/$id",
        options: Options(headers: _tokenHeader));
  }

  Future<List<ChatRecord>?> getChatRecords(int id) async {
    final Response response = await dio.get("$baseUrl/chats/$id/records",
        options: Options(headers: _tokenHeader));
    return (response.data! as List).map((e) => ChatRecord.fromJson(e)).toList();
  }

  Future<ChatRecord?> chatSendMessage(int chatId, String message) async {
    final Response response = await dio.post("$baseUrl/chats/$chatId/records",
        data: {"request": message}, options: Options(headers: _tokenHeader));
    return ChatRecord.fromJson(response.data!);
  }

  Future<ChatRecord?> chatRegenerateLast(int chatId) async {
    final Response response = await dio.put("$baseUrl/chats/$chatId/regenerate",
        options: Options(headers: _tokenHeader));
    return ChatRecord.fromJson(response.data!);
  }

  Future<void> modifyRecord(int recordId, int like) async {
    await dio.put("$baseUrl/records/$recordId",
        options: Options(headers: _tokenHeader), data: {"like": like});
  }

  Future<User?> getUserInfo() async {
    final Response response = await dio.get("$baseUrl/users/me",
        options: Options(headers: _tokenHeader));
    return User.fromJson(response.data!);
  }

  Future<void> setShareInfoConsent(bool value) async {
    await dio.put("$baseUrl/users/me",
        options: Options(headers: _tokenHeader),
        data: {"share_consent": value});
  }

  Future<RepositoryConfig?> getConfiguration() async {
    final Response response = await dio.get("$baseUrl/config");
    final Map<String, dynamic> data = response.data!;
    Region region;
    switch (data['region']) {
      case "cn":
        region = Region.CN;
        break;
      case "global":
        region = Region.Global;
        break;
      default:
        throw Exception("Unknown region");
    }
    final bool inviteRequired = data['invite_required'];
    return RepositoryConfig(region, inviteRequired);
  }
}

class RepositoryConfig {
  final Region region;
  final bool inviteRequired;

  const RepositoryConfig(this.region, this.inviteRequired);
}

class JWTInterceptor extends QueuedInterceptor {
  final Dio _dio = Dio();
  final String refreshUrl;
  final Function tokenGetter;
  final Function? tokenSetter;

  JWTInterceptor(this.refreshUrl, this.tokenGetter, [this.tokenSetter]);

  static _rewriteRequestOptionsWithToken(
      RequestOptions options, JWToken token) {
    Map<String, dynamic> newHeader =
        options.headers.map((key, value) => MapEntry(key, value));
    newHeader['Authorization'] = "Bearer ${token.access}";
    return options.copyWith(headers: newHeader);
  }

  void _throwOrBuildDioError(
      ErrorInterceptorHandler handler, RequestOptions options, dynamic error) {
    if (error is DioError) {
      handler.reject(error);
    } else {
      handler.reject(DioError(requestOptions: options, error: error));
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      JWToken? currentToken = tokenGetter.call();
      if (currentToken != null) {
        RequestOptions options = RequestOptions(
            path: refreshUrl,
            method: "POST",
            headers: {"Authorization": "Bearer ${currentToken.refresh}"});
        Response<Map<String, dynamic>> response;
        try {
          response = await _dio.fetch(options);
        } catch (e) {
          if (e is DioError && e.response?.statusCode == 401) {
            // Oh, we cannot get a token here! Maybe the refresh token we hold has gone invalid.
            // Clear old token, so the next request will definitely generate a [NotLoginError].
            tokenSetter?.call(null);
            handler.reject(e);
            return;
          }
          _throwOrBuildDioError(handler, options, e);
          return;
        }
        try {
          JWToken newToken = JWToken.fromJson(response.data!);
          tokenSetter?.call(newToken);
          handler.resolve(await _dio.fetch(
              _rewriteRequestOptionsWithToken(err.requestOptions, newToken)));
        } catch (e) {
          _throwOrBuildDioError(handler, options, e);
        }
        return;
      }
    }
    handler.next(err);
  }
}
