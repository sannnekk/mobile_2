import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/api/query_params.dart';
import 'package:mobile_2/core/entities/course.dart';

class CourseService {
  final ApiClient _client;
  CourseService({ApiClient? client}) : _client = client ?? ApiClient();

  // Fetch course assignments for a specific student
  Future<ApiResponse<CourseAssignmentEntity>> getStudentCourseAssignments(
    String studentId, {
    bool isArchived = false,
    int? page,
    int? limit,
  }) async {
    var queryParams = QueryParams.empty().addBoolFilter(
      "isArchived",
      isArchived,
    );

    if (page != null) {
      queryParams = queryParams.addPage(page);
    }
    if (limit != null) {
      queryParams = queryParams.addLimit(limit);
    }

    final resp = await _client.get<CourseAssignmentEntity>(
      path: '/course/student/$studentId',
      queryParams: queryParams,
      fromJson: (json) => CourseAssignmentEntity.fromJson(
        (json as Map).cast<String, dynamic>(),
      ),
      isList: true,
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

  // Toggle reaction for a material
  Future<ApiResponse<void>> toggleReaction(
    String materialId,
    String reaction,
  ) async {
    final resp = await _client.patch<void>(
      path: '/course/material/$materialId/react/$reaction',
      acceptEmpty: true,
    );
    return resp;
  }
}
