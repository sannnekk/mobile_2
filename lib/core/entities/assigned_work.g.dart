// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_work.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedWorkProgress _$AssignedWorkProgressFromJson(
  Map<String, dynamic> json,
) => AssignedWorkProgress(
  score: (json['score'] as num?)?.toInt(),
  maxScore: (json['maxScore'] as num).toInt(),
  solveStatus: assignedWorkSolveStatusFromJson(json['solveStatus'] as String),
  checkStatus: assignedWorkCheckStatusFromJson(json['checkStatus'] as String),
);

Map<String, dynamic> _$AssignedWorkProgressToJson(
  AssignedWorkProgress instance,
) => <String, dynamic>{
  'score': instance.score,
  'maxScore': instance.maxScore,
  'solveStatus': assignedWorkSolveStatusToJson(instance.solveStatus),
  'checkStatus': assignedWorkCheckStatusToJson(instance.checkStatus),
};

AssignedWorkAnswerEntity _$AssignedWorkAnswerEntityFromJson(
  Map<String, dynamic> json,
) => AssignedWorkAnswerEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  taskId: json['taskId'] as String,
  word: json['word'] as String?,
  content: RichText.fromJson(json['content'] as Map<String, dynamic>?),
  isSubmitted: json['isSubmitted'] as bool?,
  score: (json['score'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AssignedWorkAnswerEntityToJson(
  AssignedWorkAnswerEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'taskId': instance.taskId,
  'word': instance.word,
  'content': _richTextToJson(instance.content),
  'isSubmitted': instance.isSubmitted,
  'score': instance.score,
};

AssignedWorkCommentEntity _$AssignedWorkCommentEntityFromJson(
  Map<String, dynamic> json,
) => AssignedWorkCommentEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  taskId: json['taskId'] as String,
  content: RichText.fromJson(json['content'] as Map<String, dynamic>?),
  score: (json['score'] as num?)?.toDouble(),
  detailedScore: (json['detailedScore'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
);

Map<String, dynamic> _$AssignedWorkCommentEntityToJson(
  AssignedWorkCommentEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'taskId': instance.taskId,
  'content': _richTextToJson(instance.content),
  'score': instance.score,
  'detailedScore': instance.detailedScore,
};

AssignedWorkEntity _$AssignedWorkEntityFromJson(
  Map<String, dynamic> json,
) => AssignedWorkEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  mentorIds: (json['mentorIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  mentors: (json['mentors'] as List<dynamic>?)
      ?.map((e) => UserEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  studentId: json['studentId'] as String,
  student: json['student'] == null
      ? null
      : UserEntity.fromJson(json['student'] as Map<String, dynamic>),
  workId: json['workId'] as String?,
  solveStatus: json['solveStatus'] == null
      ? AssignedWorkSolveStatus.notSolved
      : assignedWorkSolveStatusFromJson(json['solveStatus'] as String),
  checkStatus: json['checkStatus'] == null
      ? AssignedWorkCheckStatus.notChecked
      : assignedWorkCheckStatusFromJson(json['checkStatus'] as String),
  solveDeadlineAt: json['solveDeadlineAt'] == null
      ? null
      : DateTime.parse(json['solveDeadlineAt'] as String),
  solveDeadlineShifted: json['solveDeadlineShifted'] as bool? ?? false,
  checkDeadlineAt: json['checkDeadlineAt'] == null
      ? null
      : DateTime.parse(json['checkDeadlineAt'] as String),
  checkDeadlineShifted: json['checkDeadlineShifted'] as bool? ?? false,
  solvedAt: json['solvedAt'] == null
      ? null
      : DateTime.parse(json['solvedAt'] as String),
  checkedAt: json['checkedAt'] == null
      ? null
      : DateTime.parse(json['checkedAt'] as String),
  answers:
      (json['answers'] as List<dynamic>?)
          ?.map(
            (e) => AssignedWorkAnswerEntity.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map(
            (e) =>
                AssignedWorkCommentEntity.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  score: (json['score'] as num?)?.toInt(),
  maxScore: (json['maxScore'] as num).toInt(),
  isArchivedByStudent: json['isArchivedByStudent'] as bool? ?? false,
  isArchivedByMentors: json['isArchivedByMentors'] as bool? ?? false,
  isArchivedByAssistants: json['isArchivedByAssistants'] as bool? ?? false,
);

Map<String, dynamic> _$AssignedWorkEntityToJson(AssignedWorkEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'mentorIds': instance.mentorIds,
      'mentors': instance.mentors,
      'studentId': instance.studentId,
      'student': instance.student,
      'workId': instance.workId,
      'solveStatus': assignedWorkSolveStatusToJson(instance.solveStatus),
      'checkStatus': assignedWorkCheckStatusToJson(instance.checkStatus),
      'solveDeadlineAt': instance.solveDeadlineAt?.toIso8601String(),
      'solveDeadlineShifted': instance.solveDeadlineShifted,
      'checkDeadlineAt': instance.checkDeadlineAt?.toIso8601String(),
      'checkDeadlineShifted': instance.checkDeadlineShifted,
      'solvedAt': instance.solvedAt?.toIso8601String(),
      'checkedAt': instance.checkedAt?.toIso8601String(),
      'answers': instance.answers,
      'comments': instance.comments,
      'score': instance.score,
      'maxScore': instance.maxScore,
      'isArchivedByStudent': instance.isArchivedByStudent,
      'isArchivedByMentors': instance.isArchivedByMentors,
      'isArchivedByAssistants': instance.isArchivedByAssistants,
    };
