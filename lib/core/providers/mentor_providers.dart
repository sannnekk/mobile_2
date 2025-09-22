import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';

part 'mentor_providers.g.dart';

@riverpod
Future<List<MentorAssignmentEntity>> userMentorAssignments(
  UserMentorAssignmentsRef ref,
  String username,
) async {
  final authService = await ref.watch(authServiceProvider.future);
  final response = await authService.getStudentMentorAssignments(username);
  if (response is ApiSingleResponse<List<MentorAssignmentEntity>>) {
    return response.data;
  } else {
    throw Exception('Failed to load mentor assignments');
  }
}
