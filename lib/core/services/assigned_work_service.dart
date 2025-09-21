import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/api/query_params.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';

class AssignedWorkService {
  final ApiClient _client;
  AssignedWorkService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResponse<AssignedWorkEntity>> getStudentAssignedWorks(
    String studentId, {
    bool? isArchivedByStudent,
    List<String>? solveStatuses,
    List<String>? checkStatuses,
    int? page,
    int? limit,
  }) async {
    var queryParams = QueryParams.empty();

    if (isArchivedByStudent != null) {
      queryParams = queryParams.addBoolFilter(
        "isArchivedByStudent",
        isArchivedByStudent,
      );
    }

    if (solveStatuses != null && solveStatuses.isNotEmpty) {
      queryParams = queryParams.addArrayFilter("solveStatus", solveStatuses);
    }

    if (checkStatuses != null && checkStatuses.isNotEmpty) {
      queryParams = queryParams.addArrayFilter("checkStatus", checkStatuses);
    }

    if (page != null) {
      queryParams = queryParams.addPage(page);
    }
    if (limit != null) {
      queryParams = queryParams.addLimit(limit);
    }

    final resp = await _client.get<AssignedWorkEntity>(
      path: '/assigned-work',
      queryParams: queryParams,
      fromJson: (json) =>
          AssignedWorkEntity.fromJson((json as Map).cast<String, dynamic>()),
      isList: true,
    );
    return resp;
  }

  Future<ApiResponse<AssignedWorkEntity>> getAssignedWork(String workId) async {
    final resp = await _client.get<AssignedWorkEntity>(
      path: '/assigned-work/$workId',
      fromJson: (json) =>
          AssignedWorkEntity.fromJson((json as Map).cast<String, dynamic>()),
    );
    return resp;
  }

  // Archive assigned work
  Future<ApiResponse<void>> archiveAssignedWork(String workId) async {
    final resp = await _client.patch<void>(
      path: '/assigned-work/$workId/archive',
      acceptEmpty: true,
    );
    return resp;
  }

  // Delete assigned work
  Future<ApiResponse<void>> deleteAssignedWork(String workId) async {
    final resp = await _client.delete<void>(
      path: '/assigned-work/$workId',
      acceptEmpty: true,
    );
    return resp;
  }

  // Save answer for assigned work
  Future<ApiResponse<String>> saveAnswer(
    String assignedWorkId,
    AssignedWorkAnswerEntity answer,
  ) async {
    final resp = await _client.patch<String>(
      path: '/assigned-work/$assignedWorkId/save-answer',
      body: answer.toJson(),
      fromJson: (json) => json as String,
    );
    return resp;
  }

  // Solve assigned work
  Future<ApiResponse<void>> solveAssignedWork(
    String assignedWorkId,
    List<AssignedWorkAnswerEntity> answers,
  ) async {
    final resp = await _client.patch<void>(
      path: '/assigned-work/$assignedWorkId/solve',
      body: {'answers': answers.map((a) => a.toJson()).toList()},
      acceptEmpty: true,
    );
    return resp;
  }
}
