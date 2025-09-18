import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/api/query_params.dart';
import 'package:mobile_2/core/entities/course.dart';

class CourseService {
  final ApiClient _client;
  CourseService({ApiClient? client}) : _client = client ?? ApiClient();

  // Fetch course assignments for a specific student
  Future<ApiResponse<List<CourseAssignmentEntity>>> getStudentCourseAssignments(
    String studentId, {
    bool isArchived = false,
  }) async {
    final queryParams = QueryParams.empty().addBoolFilter(
      "isArchived",
      isArchived,
    );

    final resp = await _client.get<List<CourseAssignmentEntity>>(
      path: '/course/student/$studentId',
      queryParams: queryParams,
      fromJson: (json) => (json as List)
          .map(
            (e) => CourseAssignmentEntity.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
      isList: false,
    );
    return resp;
  }

  // Fetch course by slug
  Future<ApiResponse<CourseEntity>> getCourseBySlug(String slug) async {
    final resp = await _client.get<CourseEntity>(
      path: '/course/$slug',
      fromJson: (json) {
        return CourseEntity.fromJson(json);
      },
      isList: false,
    );
    return resp;
  }
}
