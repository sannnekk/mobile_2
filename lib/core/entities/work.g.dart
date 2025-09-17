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
  type: $enumDecode(_$WorkTypeEnumMap, json['type']),
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
      'type': _$WorkTypeEnumMap[instance.type]!,
      'description': instance.description,
      'subject': instance.subject,
      'subjectId': instance.subjectId,
      'tasks': instance.tasks,
    };

const _$WorkTypeEnumMap = {
  WorkType.test: 'test',
  WorkType.miniTest: 'miniTest',
  WorkType.phrase: 'phrase',
  WorkType.secondPart: 'secondPart',
  WorkType.trialWork: 'trialWork',
};

WorkTaskEntity _$WorkTaskEntityFromJson(Map<String, dynamic> json) =>
    WorkTaskEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      workId: json['workId'] as String,
      type: $enumDecode(_$WorkTaskTypeEnumMap, json['type']),
      content: RichText.fromJson(json['content'] as Map<String, dynamic>?),
      highestScore: (json['highestScore'] as num).toInt(),
      order: (json['order'] as num).toInt(),
      checkHint: RichText.fromJson(json['checkHint'] as Map<String, dynamic>?),
      solveHint: RichText.fromJson(json['solveHint'] as Map<String, dynamic>?),
      rightAnswer: json['rightAnswer'] as String?,
      checkingStrategy: $enumDecodeNullable(
        _$TaskCheckingStrategyEnumMap,
        json['checkingStrategy'],
      ),
      isAnswerVisibleBeforeCheck:
          json['isAnswerVisibleBeforeCheck'] as bool? ?? false,
      isCheckOneByOneEnabled: json['isCheckOneByOneEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkTaskEntityToJson(
  WorkTaskEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'workId': instance.workId,
  'type': _$WorkTaskTypeEnumMap[instance.type]!,
  'content': _richTextToJson(instance.content),
  'checkHint': _richTextToJson(instance.checkHint),
  'solveHint': _richTextToJson(instance.solveHint),
  'rightAnswer': instance.rightAnswer,
  'highestScore': instance.highestScore,
  'order': instance.order,
  'isAnswerVisibleBeforeCheck': instance.isAnswerVisibleBeforeCheck,
  'isCheckOneByOneEnabled': instance.isCheckOneByOneEnabled,
  'checkingStrategy': _$TaskCheckingStrategyEnumMap[instance.checkingStrategy],
};

const _$WorkTaskTypeEnumMap = {
  WorkTaskType.word: 'word',
  WorkTaskType.text: 'text',
  WorkTaskType.essay: 'essay',
  WorkTaskType.finalEssay: 'finalEssay',
  WorkTaskType.dictation: 'dictation',
};

const _$TaskCheckingStrategyEnumMap = {
  TaskCheckingStrategy.type1: 'type1',
  TaskCheckingStrategy.type2: 'type2',
  TaskCheckingStrategy.type3: 'type3',
  TaskCheckingStrategy.type4: 'type4',
};
