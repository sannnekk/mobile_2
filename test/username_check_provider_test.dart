import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_config.dart';
import 'package:mobile_2/core/providers/username_check_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockUsernameCheckFlow extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
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
  late ProviderContainer container;
  late ApiClient client;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    client = ApiClient();
    try {
      await client.init(
        config: ApiConfig(
          baseUrl: 'http://test.com',
          connectTimeout: Duration(seconds: 5),
          receiveTimeout: Duration(seconds: 5),
        ),
        dio: Dio()..interceptors.add(_MockUsernameCheckFlow()),
      );
    } catch (_) {
      // Already initialized
    }
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('UsernameCheckNotifier starts with initial state', () {
    final state = container.read(usernameCheckProvider);

    expect(state.status, UsernameCheckStatus.initial);
    expect(state.error, null);
  });

  test('UsernameCheckNotifier handles empty username', () {
    final notifier = container.read(usernameCheckProvider.notifier);

    notifier.checkUsername('');
    var state = container.read(usernameCheckProvider);
    expect(state.status, UsernameCheckStatus.initial);

    notifier.checkUsername('ab');
    state = container.read(usernameCheckProvider);
    expect(state.status, UsernameCheckStatus.initial);
  });

  test('UsernameCheckNotifier shows checking status immediately', () {
    container.read(usernameCheckProvider.notifier).checkUsername('testuser');
    final state = container.read(usernameCheckProvider);
    expect(state.status, UsernameCheckStatus.checking);

    // The debounced call would happen after 500ms, but we don't wait for it in this test
  });

  // Note: Testing the debounced API call would require async testing with delays
  // For now, the basic functionality is tested
}
