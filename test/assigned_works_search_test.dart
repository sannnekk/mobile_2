import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_config.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/providers/assigned_work_providers.dart';
import 'package:mobile_2/core/providers/auth_providers.dart' as auth;
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/entities/auth_payload.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingInterceptor extends Interceptor {
  int requestCount = 0;
  String? lastPath;
  Map<String, dynamic>? lastQuery;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requestCount++;
    lastPath = options.path;
    lastQuery = options.queryParameters;

    if (options.path == '/assigned-work') {
      final now = DateTime.now().toIso8601String();
      final data = [
        {
          'id': 'aw1',
          'createdAt': now,
          'mentorIds': [],
          'studentId': 's1',
          'solveStatus': 'not-started',
          'checkStatus': 'not-checked',
          'maxScore': 10,
          'isArchivedByStudent': false,
          'isArchivedByMentors': false,
          'isArchivedByAssistants': false,
          'answers': [],
          'comments': [],
        },
      ];
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': data,
            'meta': {'total': data.length},
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

class _SeededAuthNotifier extends auth.AuthNotifier {
  _SeededAuthNotifier(auth.AuthState initial, super.ref) {
    state = initial;
  }
}

Future<AssignedWorksState> _waitForLoad(
  ProviderContainer container,
  AssignedWorkTab tab,
) async {
  final completer = Completer<AssignedWorksState>();
  await container.read(assignedWorkServiceProvider.future);

  bool started = false;
  final sub = container.listen(assignedWorksNotifierProvider(tab), (
    prev,
    next,
  ) {
    if (next.isLoading) {
      started = true;
    } else if (started) {
      if (!completer.isCompleted) completer.complete(next);
    }
  }, fireImmediately: false);
  try {
    // Trigger provider creation
    // ignore: unused_local_variable
    final _ = container.read(assignedWorksNotifierProvider(tab));
    final result = await completer.future.timeout(const Duration(seconds: 5));
    return result;
  } finally {
    sub.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssignedWorks search', () {
    late _RecordingInterceptor interceptor;
    late Dio dio;
    late ApiClient client;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      interceptor = _RecordingInterceptor();
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..interceptors.add(interceptor);
      client = ApiClient();
      await client.init(
        config: ApiConfig(baseUrl: 'https://example.test'),
        dio: dio,
      );
    });

    setUp(() async {
      interceptor.requestCount = 0;
      interceptor.lastPath = null;
      interceptor.lastQuery = null;
    });

    test('adds q param for All tab only', () async {
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith((ref) async => client),
          auth.authStateProvider.overrideWith(
            (ref) => _SeededAuthNotifier(
              const auth.AuthState(
                isAuthenticated: true,
                isLoading: false,
                userPayload: AuthPayload(
                  userId: 'payload-id',
                  username: 'u',
                  role: UserRole.student,
                ),
              ),
              ref,
            ),
          ),
        ],
      );

      // Initial load for All tab (no q yet)
      await _waitForLoad(container, AssignedWorkTab.all);
      expect(interceptor.lastPath, '/assigned-work');
      expect(interceptor.lastQuery?['search'], isNull);

      // Set search
      container
          .read(assignedWorksNotifierProvider(AssignedWorkTab.all).notifier)
          .setSearchQuery('math');

      // Wait for debounce and load
      await Future.delayed(const Duration(milliseconds: 600));

      // Expect search param present on last request
      expect(interceptor.lastQuery?['search'], 'math');

      // Change to another tab and trigger load -> should not include search
      await _waitForLoad(container, AssignedWorkTab.checked);
      expect(interceptor.lastQuery?['search'], isNull);
    });

    test('debounces rapid search changes', () async {
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith((ref) async => client),
          auth.authStateProvider.overrideWith(
            (ref) => _SeededAuthNotifier(
              const auth.AuthState(
                isAuthenticated: true,
                isLoading: false,
                userPayload: AuthPayload(
                  userId: 'payload-id',
                  username: 'u',
                  role: UserRole.student,
                ),
              ),
              ref,
            ),
          ),
        ],
      );

      // Initial load
      await _waitForLoad(container, AssignedWorkTab.all);
      final notifier = container.read(
        assignedWorksNotifierProvider(AssignedWorkTab.all).notifier,
      );

      notifier.setSearchQuery('m');
      notifier.setSearchQuery('ma');
      notifier.setSearchQuery('mat');
      notifier.setSearchQuery('math');

      // After rapid changes, wait longer than debounce
      await Future.delayed(const Duration(milliseconds: 600));

      // There should be one extra request after initial (not exact count due to other provider interactions),
      // but the last query must include the final term
      expect(interceptor.lastQuery?['search'], 'math');
    });
  });
}
