import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_config.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/providers/course_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_2/core/providers/auth_providers.dart' as auth;
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/entities/auth_payload.dart';

class _RecordingInterceptor extends Interceptor {
  int requestCount = 0;
  String? lastPath;
  Map<String, dynamic>? lastQuery;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requestCount++;
    lastPath = options.path;
    lastQuery = options.queryParameters;

    // Only handle the course assignments endpoint
    if (options.path.startsWith('/course/student/')) {
      final isArchived =
          (options.queryParameters['filter[isArchived]'] ?? 'false') == 'true';
      final now = DateTime.now().toIso8601String();
      final data = [
        {
          'id': 'ca1-${isArchived ? 'arch' : 'act'}',
          'createdAt': now,
          'courseId': 'c1',
          'studentId': 'stub',
          'isArchived': isArchived,
          'isPinned': false,
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

Future<CourseAssignmentsState> _waitForLoad(
  ProviderContainer container,
  bool isArchived,
) async {
  final completer = Completer<CourseAssignmentsState>();
  // Ensure the dependent FutureProvider resolves so the notifier is built with a real CourseService
  await container.read(courseServiceProvider.future);

  bool started = false;
  final sub = container.listen(courseAssignmentsNotifierProvider(isArchived), (
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
    final _ = container.read(courseAssignmentsNotifierProvider(isArchived));
    final result = await completer.future.timeout(const Duration(seconds: 5));
    return result;
  } finally {
    sub.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CourseAssignments provider', () {
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
      // reset counters before each test
      interceptor.requestCount = 0;
      interceptor.lastPath = null;
      interceptor.lastQuery = null;
    });

    test('uses payload id and sets isArchived=false for All tab', () async {
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

      final state = await _waitForLoad(container, false);

      expect(interceptor.requestCount, 1);
      expect(interceptor.lastPath, '/course/student/payload-id');
      expect(interceptor.lastQuery?['filter[isArchived]'], 'false');
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.assignments, isA<List<CourseAssignmentEntity>>());
      expect(state.assignments.length, 1);
      expect(state.assignments.first.isArchived, false);
    });

    test('uses user.id and sets isArchived=true for Archived tab', () async {
      final seededUser = UserEntity(
        id: 'user-id',
        createdAt: DateTime.now(),
        name: 'U',
        email: 'u@e',
        role: UserRole.student,
        username: 'u',
        telegramNotificationsEnabled: false,
        isBlocked: false,
      );

      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith((ref) async => client),
          auth.authStateProvider.overrideWith(
            (ref) => _SeededAuthNotifier(
              auth.AuthState(
                isAuthenticated: true,
                isLoading: false,
                user: seededUser,
                userPayload: null,
              ),
              ref,
            ),
          ),
        ],
      );

      final state = await _waitForLoad(container, true);

      expect(interceptor.requestCount, 1);
      expect(interceptor.lastPath, '/course/student/user-id');
      expect(interceptor.lastQuery?['filter[isArchived]'], 'true');
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.assignments.length, 1);
      expect(state.assignments.first.isArchived, true);
    });

    test('logs out when id is missing', () async {
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith((ref) async => client),
          auth.authStateProvider.overrideWith(
            (ref) => _SeededAuthNotifier(
              const auth.AuthState(
                isAuthenticated: true,
                isLoading: false,
                userPayload: null,
              ),
              ref,
            ),
          ),
        ],
      );

      final state = await _waitForLoad(container, false);

      // Logout request performed
      expect(interceptor.requestCount, 1);
      expect(interceptor.lastPath, '/session/current');
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.assignments.length, 0);
    });
  });
}
