import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:dio/dio.dart';
import 'package:openchat_frontend/utils/settings_provider.dart';

class Repository {
  static final _instance = Repository._();

  factory Repository.getInstance() => _instance;

  static const String baseUrl = "https://moss.jingyijun.xyz:12443/api";

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

  Future<void> requestEmailVerifyCode(String email) async {
    await dio.get("$baseUrl/verify/email", queryParameters: {"email": email});
  }

  Future<void> requestPhoneVerifyCode(String phone) async {
    await dio.get("$baseUrl/verify/phone", queryParameters: {"phone": phone});
  }

  Future<JWToken?> registerWithEmailPassword(
      String email, String password, String verifyCode) async {
    final Response<Map<String, dynamic>> response =
        await dio.post("$baseUrl/register", data: {
      "password": password,
      "email": email,
      "verification": verifyCode,
    });
    return provider.token =
        SettingsProvider.getInstance().token = JWToken.fromJson(response.data!);
  }

  Future<JWToken?> registerWithPhonePassword(
      String phone, String password, String verifyCode) async {
    final Response<Map<String, dynamic>> response =
        await dio.post("$baseUrl/register", data: {
      "password": password,
      "phone": phone,
      "verification": verifyCode,
    });
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
  }

  Map<String, String> get _tokenHeader {
    assert(provider.token != null);
    return {"Authorization": "Bearer ${provider.token!.access}"};
  }
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
    newHeader['Authorization'] = token.access;
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
