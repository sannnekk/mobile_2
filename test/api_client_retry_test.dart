import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/api/api_config.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockFlowInterceptor extends Interceptor {
  int callCount = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    callCount++;
    if (options.path == '/secure' && callCount == 1) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 401,
          data: {'error': 'Unauthorized'},
        ),
      );
      return;
    }
    if (options.path == '/auth/login') {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': {
              'token': 'token-123',
              'payload': {'username': 'john'},
            },
          },
        ),
      );
      return;
    }
    if (options.path == '/secure' && callCount >= 3) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': {'message': 'ok'},
          },
        ),
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
  test('ApiClient retries after 401 by prompting login and succeeds', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final interceptor = _MockFlowInterceptor();
    dio.interceptors.add(interceptor);

    final client = ApiClient();
    await client.init(
      config: ApiConfig(baseUrl: 'https://example.test'),
      dio: dio,
    );

    // Provide a fake prompt that returns a password (any string)
    client.promptPassword = () async => 'secret';

    // Stub payload so login has a username
    await client.setToken('expired-token', {'username': 'john'});

    final resp = await client.get<Map<String, dynamic>>(path: '/secure');
    expect(resp is ApiSingleResponse<Map<String, dynamic>>, isTrue);
    final data = (resp as ApiSingleResponse<Map<String, dynamic>>).data;
    expect(data['message'], 'ok');
    // Ensure multiple steps: 401 -> login -> retry
    expect(interceptor.callCount, greaterThanOrEqualTo(3));
  });
}
