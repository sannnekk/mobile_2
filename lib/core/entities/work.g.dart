// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkEntity _$WorkEntityFromJson(Map<String, dynamic> json) => WorkEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  slug: json['slug'] as String,
  name: json['name'] as String,
  type: WorkEntity.workTypeFromJson(json['type'] as String),
  description: json['description'] as String?,
  subject: json['subject'] == null
      ? null
      : SubjectEntity.fromJson(json['subject'] as Map<String, dynamic>),
  subjectId: json['subjectId'] as String?,
  tasks: (json['tasks'] as List<dynamic>?)
      ?.map((e) => WorkTaskEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WorkEntityToJson(WorkEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'slug': instance.slug,
      'name': instance.name,
      'type': WorkEntity.workTypeToJson(instance.type),
      'description': instance.description,
      'subject': instance.subject,
      'subjectId': instance.subjectId,
      'tasks': instance.tasks,
    };

WorkTaskEntity _$WorkTaskEntityFromJson(Map<String, dynamic> json) =>
    WorkTaskEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      workId: json['workId'] as String,
      type: WorkTaskEntity.workTaskTypeFromJson(json['type'] as String),
      content: RichText.fromJson(json['content'] as Map<String, dynamic>?),
      highestScore: (json['highestScore'] as num).toInt(),
      order: (json['order'] as num).toInt(),
      checkHint: const RichTextConverter().fromJson(
        json['checkHint'] as Map<String, dynamic>?,
      ),
      solveHint: const RichTextConverter().fromJson(
        json['solveHint'] as Map<String, dynamic>?,
      ),
      rightAnswer: json['rightAnswer'] as String?,
      checkingStrategy: WorkTaskEntity.taskCheckingStrategyFromJson(
        json['checkingStrategy'] as String?,
      ),
      isAnswerVisibleBeforeCheck:
          json['isAnswerVisibleBeforeCheck'] as bool? ?? false,
      isCheckOneByOneEnabled: json['isCheckOneByOneEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkTaskEntityToJson(WorkTaskEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'workId': instance.workId,
      'type': WorkTaskEntity.workTaskTypeToJson(instance.type),
      'content': instance.content,
      'checkHint': const RichTextConverter().toJson(instance.checkHint),
      'solveHint': const RichTextConverter().toJson(instance.solveHint),
      'rightAnswer': instance.rightAnswer,
      'highestScore': instance.highestScore,
      'order': instance.order,
      'isAnswerVisibleBeforeCheck': instance.isAnswerVisibleBeforeCheck,
      'isCheckOneByOneEnabled': instance.isCheckOneByOneEnabled,
      'checkingStrategy': WorkTaskEntity.taskCheckingStrategyToJson(
        instance.checkingStrategy,
      ),
    };
