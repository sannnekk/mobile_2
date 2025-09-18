// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollEntity _$PollEntityFromJson(Map<String, dynamic> json) => PollEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  title: json['title'] as String,
  description: json['description'] as String?,
  canVote: PollEntity.canVoteFromJson(json['canVote'] as List),
  canSeeResults: PollEntity.canSeeResultsFromJson(
    json['canSeeResults'] as List,
  ),
  requireAuth: json['requireAuth'] as bool? ?? false,
  stopAt: json['stopAt'] == null
      ? null
      : DateTime.parse(json['stopAt'] as String),
  isStopped: json['isStopped'] as bool? ?? false,
  questions:
      (json['questions'] as List<dynamic>?)
          ?.map((e) => PollQuestionEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  votedCount: (json['votedCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$PollEntityToJson(PollEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'canVote': PollEntity.canVoteToJson(instance.canVote),
      'canSeeResults': PollEntity.canSeeResultsToJson(instance.canSeeResults),
      'requireAuth': instance.requireAuth,
      'stopAt': instance.stopAt?.toIso8601String(),
      'isStopped': instance.isStopped,
      'questions': instance.questions,
      'votedCount': instance.votedCount,
    };

PollQuestionEntity _$PollQuestionEntityFromJson(Map<String, dynamic> json) =>
    PollQuestionEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      pollId: json['pollId'] as String,
      text: json['text'] as String,
      description: json['description'] as String?,
      type: PollQuestionEntity.questionTypeFromJson(json['type'] as String),
      isRequired: json['required'] as bool? ?? false,
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => PollAnswerEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      choices: (json['choices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      minChoices: (json['minChoices'] as num?)?.toInt() ?? 0,
      maxChoices: (json['maxChoices'] as num?)?.toInt() ?? 0,
      minRating: (json['minRating'] as num?)?.toInt(),
      maxRating: (json['maxRating'] as num?)?.toInt(),
      onlyIntegerRating: json['onlyIntegerRating'] as bool?,
      allowedFileTypes: (json['allowedFileTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maxFileSize: (json['maxFileSize'] as num?)?.toInt(),
      maxFileCount: (json['maxFileCount'] as num?)?.toInt(),
      minLength: (json['minLength'] as num?)?.toInt(),
      maxLength: (json['maxLength'] as num?)?.toInt(),
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
      onlyIntegerValue: json['onlyIntegerValue'] as bool?,
      onlyFutureDate: json['onlyFutureDate'] as bool?,
      onlyPastDate: json['onlyPastDate'] as bool?,
    );

Map<String, dynamic> _$PollQuestionEntityToJson(PollQuestionEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'pollId': instance.pollId,
      'text': instance.text,
      'description': instance.description,
      'type': PollQuestionEntity.questionTypeToJson(instance.type),
      'required': instance.isRequired,
      'answers': instance.answers,
      'choices': instance.choices,
      'minChoices': instance.minChoices,
      'maxChoices': instance.maxChoices,
      'minRating': instance.minRating,
      'maxRating': instance.maxRating,
      'onlyIntegerRating': instance.onlyIntegerRating,
      'allowedFileTypes': instance.allowedFileTypes,
      'maxFileSize': instance.maxFileSize,
      'maxFileCount': instance.maxFileCount,
      'minLength': instance.minLength,
      'maxLength': instance.maxLength,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'onlyIntegerValue': instance.onlyIntegerValue,
      'onlyFutureDate': instance.onlyFutureDate,
      'onlyPastDate': instance.onlyPastDate,
    };

PollAnswerEntity _$PollAnswerEntityFromJson(Map<String, dynamic> json) =>
    PollAnswerEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      questionId: json['questionId'] as String,
      text: json['text'] as String?,
      number: (json['number'] as num?)?.toDouble(),
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => MediaEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      choices: (json['choices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PollAnswerEntityToJson(PollAnswerEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'questionId': instance.questionId,
      'text': instance.text,
      'number': instance.number,
      'date': instance.date?.toIso8601String(),
      'files': instance.files,
      'choices': instance.choices,
      'rating': instance.rating,
    };
