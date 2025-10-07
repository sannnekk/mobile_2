import 'package:dio/dio.dart';

typedef TokenProvider = String? Function();

class AuthInterceptor extends Interceptor {
  final TokenProvider tokenProvider;

  AuthInterceptor(this.tokenProvider);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenProvider();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['X-Origin'] = 'android/app';

    handler.next(options);
  }
}
