import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_config.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/services/course_service.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCourseFlow extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    if (path.startsWith('/course/student/')) {
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

void main() {
  late ApiClient client;
  late CourseService service;

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
        dio: Dio()..interceptors.add(_MockCourseFlow()),
      );
    } catch (_) {
      // Already initialized
    }
    service = CourseService(client: client);
  });

  test(
    'CourseService getStudentCourseAssignments returns assignments',
    () async {
      final resp = await service.getStudentCourseAssignments(
        'stub',
        isArchived: false,
      );
      expect(resp is ApiListResponse<CourseAssignmentEntity>, isTrue);
      final listResp = resp as ApiListResponse<CourseAssignmentEntity>;
      expect(listResp.data.length, 1);
      expect(listResp.data.first.id, 'ca1-act');
      expect(listResp.data.first.isArchived, false);
    },
  );

  test('CourseService getStudentCourseAssignments handles archived', () async {
    final resp = await service.getStudentCourseAssignments(
      'stub',
      isArchived: true,
    );
    expect(resp is ApiListResponse<CourseAssignmentEntity>, isTrue);
    final listResp = resp as ApiListResponse<CourseAssignmentEntity>;
    expect(listResp.data.length, 1);
    expect(listResp.data.first.id, 'ca1-arch');
    expect(listResp.data.first.isArchived, true);
  });
}
