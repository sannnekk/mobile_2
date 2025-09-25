import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/api/richtext_converter.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/types/api_entity.dart';
import 'package:mobile_2/core/types/richtext.dart';
import 'package:mobile_2/core/entities/enum_helpers.dart';

part 'assigned_work.g.dart';

// Server sends enums in kebab-case; convert to/from camelCase names
enum AssignedWorkSolveStatus {
  notStarted,
  inProgress,
  madeInDeadline,
  madeAfterDeadline,
}

enum AssignedWorkCheckStatus {
  notChecked,
  inProgress,
  checkedInDeadline,
  checkedAfterDeadline,
  checkedAutomatically,
}

@JsonSerializable()
class AssignedWorkProgress {
  final int? score;
  final int maxScore;
  @JsonKey(
    fromJson: AssignedWorkEntity._solveStatusFromString,
    toJson: AssignedWorkEntity._solveStatusToString,
  )
  final AssignedWorkSolveStatus solveStatus;
  @JsonKey(
    fromJson: AssignedWorkEntity._checkStatusFromString,
    toJson: AssignedWorkEntity._checkStatusToString,
  )
  final AssignedWorkCheckStatus checkStatus;

  const AssignedWorkProgress({
    this.score,
    required this.maxScore,
    required this.solveStatus,
    required this.checkStatus,
  });

  factory AssignedWorkProgress.fromJson(Map<String, dynamic> json) =>
      _$AssignedWorkProgressFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedWorkProgressToJson(this);
}

@JsonSerializable()
class AssignedWorkAnswerEntity extends ApiEntity {
  final String taskId;
  final String? word;
  @RichTextConverter()
  final RichText? content;
  final bool? isSubmitted;
  final double? score;

  AssignedWorkAnswerEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.taskId,
    this.word,
    this.content,
    this.isSubmitted,
    this.score,
  });

  factory AssignedWorkAnswerEntity.fromJson(Map<String, dynamic> json) =>
      _$AssignedWorkAnswerEntityFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$AssignedWorkAnswerEntityToJson(this);

    if (json['id'] == null || (json['id'] as String).trim() == '') {
      json.remove('id');
    }

    return json;
  }
}

@JsonSerializable()
class AssignedWorkCommentEntity extends ApiEntity {
  final String taskId;
  @RichTextConverter()
  final RichText? content;
  final double? score;
  final Map<String, int>? detailedScore;

  AssignedWorkCommentEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.taskId,
    this.content,
    this.score,
    this.detailedScore,
  });

  factory AssignedWorkCommentEntity.fromJson(Map<String, dynamic> json) =>
      _$AssignedWorkCommentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AssignedWorkCommentEntityToJson(this);
}

@JsonSerializable()
class AssignedWorkEntity extends ApiEntity {
  final List<String> mentorIds;
  final List<UserEntity>? mentors;
  final String studentId;
  final UserEntity? student;
  final String? workId;
  final WorkEntity? work;
  @RichTextConverter()
  final RichText? studentComment;
  @RichTextConverter()
  final RichText? mentorComment;
  @JsonKey(
    fromJson: AssignedWorkEntity._solveStatusFromString,
    toJson: AssignedWorkEntity._solveStatusToString,
  )
  final AssignedWorkSolveStatus solveStatus;
  @JsonKey(
    fromJson: AssignedWorkEntity._checkStatusFromString,
    toJson: AssignedWorkEntity._checkStatusToString,
  )
  final AssignedWorkCheckStatus checkStatus;
  final DateTime? solveDeadlineAt;
  final bool solveDeadlineShifted;
  final DateTime? checkDeadlineAt;
  final bool checkDeadlineShifted;
  final DateTime? solvedAt;
  final DateTime? checkedAt;
  @JsonKey(defaultValue: [])
  final List<AssignedWorkAnswerEntity> answers;
  @JsonKey(defaultValue: [])
  final List<AssignedWorkCommentEntity> comments;
  final int? score;
  final int maxScore;
  final bool isArchivedByStudent;
  final bool isArchivedByMentors;
  final bool isArchivedByAssistants;

  AssignedWorkEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.mentorIds,
    this.mentors,
    required this.studentId,
    this.student,
    this.workId,
    this.work,
    this.studentComment,
    this.mentorComment,
    this.solveStatus = AssignedWorkSolveStatus.notStarted,
    this.checkStatus = AssignedWorkCheckStatus.notChecked,
    this.solveDeadlineAt,
    this.solveDeadlineShifted = false,
    this.checkDeadlineAt,
    this.checkDeadlineShifted = false,
    this.solvedAt,
    this.checkedAt,
    this.answers = const [],
    this.comments = const [],
    this.score,
    required this.maxScore,
    this.isArchivedByStudent = false,
    this.isArchivedByMentors = false,
    this.isArchivedByAssistants = false,
  });

  factory AssignedWorkEntity.fromJson(Map<String, dynamic> json) =>
      _$AssignedWorkEntityFromJson(json);

  get isChecked =>
      checkStatus == AssignedWorkCheckStatus.checkedInDeadline ||
      checkStatus == AssignedWorkCheckStatus.checkedAfterDeadline ||
      checkStatus == AssignedWorkCheckStatus.checkedAutomatically;

  get isMade =>
      solveStatus == AssignedWorkSolveStatus.madeAfterDeadline ||
      solveStatus == AssignedWorkSolveStatus.madeInDeadline;

  get isRemakeable => work?.type == WorkType.test && isChecked;

  get deadlineShifteable =>
      solveDeadlineAt != null &&
      DateTime.now().isBefore(solveDeadlineAt!) &&
      !isMade;

  Map<String, dynamic> toJson() => _$AssignedWorkEntityToJson(this);

  static String _solveStatusToString(AssignedWorkSolveStatus status) =>
      enumToString(status);

  static AssignedWorkSolveStatus _solveStatusFromString(String status) =>
      enumFromString(AssignedWorkSolveStatus.values, status);

  static String _checkStatusToString(AssignedWorkCheckStatus status) =>
      enumToString(status);

  static AssignedWorkCheckStatus _checkStatusFromString(String status) =>
      enumFromString(AssignedWorkCheckStatus.values, status);
}
