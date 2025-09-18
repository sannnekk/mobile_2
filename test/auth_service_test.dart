import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_config.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:mobile_2/core/services/auth_service_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuthFlow extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    if (path == '/auth/login') {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': {
              'token': 'abc123',
              'payload': {
                'userId': 'u1',
                'username': 'john',
                'role': 'student',
              },
              'user': {
                'id': 'u1',
                'createdAt': DateTime.now().toIso8601String(),
                'name': 'John',
                'email': 'john@example.com',
                'role': 'student',
                'username': 'john',
                'telegramNotificationsEnabled': false,
                'isBlocked': false,
              },
            },
          },
        ),
      );
      return;
    }
    if (path.startsWith('/auth/check-username/')) {
      final username = path.split('/').last;
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': {'exists': username == 'taken'},
          },
        ),
      );
      return;
    }
    if (path == '/auth/register' ||
        path == '/auth/forgot-password' ||
        path == '/session/current') {
      handler.resolve(
        Response(requestOptions: options, statusCode: 204, data: null),
      );
      return;
    }

    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 404,
        data: {'error': 'Not found'},
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late ApiClient client;
  late Dio dio;

  setUpAll(() async {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(_MockAuthFlow());
    client = ApiClient();
    await client.init(
      config: ApiConfig(baseUrl: 'https://example.test'),
      dio: dio,
    );
  });

  test('AuthService login stores token and returns user', () async {
    final service = AuthService(client: client);
    final resp = await service.login(
      const AuthLoginRequest(usernameOrEmail: 'john', password: 'pw'),
    );
    expect(resp is ApiSingleResponse<AuthLoginResponse>, isTrue);

    final loginData = (resp as ApiSingleResponse<AuthLoginResponse>).data;
    expect(loginData.token, 'abc123');
    expect(client.token, 'abc123');
    expect(loginData.user.username, 'john');
  });

  test('AuthService checkUsername maps exists', () async {
    final service = AuthService(client: client);

    final available = await service.checkUsername('free');
    expect(available is ApiSingleResponse<CheckUsernameResponse>, isTrue);
    expect(
      (available as ApiSingleResponse<CheckUsernameResponse>).data.exists,
      false,
    ); // 'free' does not exist

    final taken = await service.checkUsername('taken');
    expect(taken is ApiSingleResponse<CheckUsernameResponse>, isTrue);
    expect(
      (taken as ApiSingleResponse<CheckUsernameResponse>).data.exists,
      true,
    );
  });

  test('AuthService register and forgotPassword accept empty', () async {
    final service = AuthService(client: client);

    final reg = await service.register(
      const AuthRegisterRequest(
        name: 'John',
        email: 'john@example.com',
        username: 'john',
        password: 'pw',
      ),
    );
    expect(reg is ApiEmptyResponse, isTrue);

    final fp = await service.forgotPassword(
      const AuthForgotPasswordRequest('john@example.com'),
    );
    expect(fp is ApiEmptyResponse, isTrue);
  });

  test('AuthService logout makes DELETE request', () async {
    final service = AuthService(client: client);

    final resp = await service.logout();
    expect(resp is ApiEmptyResponse, isTrue);
  });
}
