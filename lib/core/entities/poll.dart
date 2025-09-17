import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/core/types/api_entity.dart';

part 'poll.g.dart';

enum PollVisibility { everyone, student, mentor, assistant, teacher, admin }

enum PollQuestionType { text, number, date, file, choice, rating }

@JsonSerializable()
class PollEntity extends ApiEntity {
  final String title;
  final String? description;
  final List<PollVisibility> canVote;
  final List<PollVisibility> canSeeResults;
  final bool requireAuth;
  final DateTime? stopAt;
  final bool isStopped;
  final List<PollQuestionEntity> questions;
  final int? votedCount;

  PollEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.title,
    this.description,
    required this.canVote,
    required this.canSeeResults,
    this.requireAuth = false,
    this.stopAt,
    this.isStopped = false,
    this.questions = const [],
    this.votedCount,
  });

  factory PollEntity.fromJson(Map<String, dynamic> json) =>
      _$PollEntityFromJson(json);
  Map<String, dynamic> toJson() => _$PollEntityToJson(this);
}

@JsonSerializable()
class PollQuestionEntity extends ApiEntity {
  final String pollId;
  final String text;
  final String? description;
  final PollQuestionType type;
  final bool isRequired; // !!! the json field name is "required"
  final List<PollAnswerEntity>? answers;

  // options for choices
  final List<String>? choices;
  final int minChoices;
  final int maxChoices;

  // options for rating
  final int? minRating;
  final int? maxRating;
  final bool? onlyIntegerRating;

  // options for files
  final List<String>? allowedFileTypes;
  final int? maxFileSize;
  final int? maxFileCount;

  // options for text
  final int? minLength;
  final int? maxLength;

  // options for number
  final double? minValue;
  final double? maxValue;
  final bool? onlyIntegerValue;

  // options for date
  final bool? onlyFutureDate;
  final bool? onlyPastDate;

  PollQuestionEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.pollId,
    required this.text,
    this.description,
    required this.type,
    this.isRequired = false,
    this.answers,
    this.choices,
    this.minChoices = 0,
    this.maxChoices = 0,
    this.minRating,
    this.maxRating,
    this.onlyIntegerRating,
    this.allowedFileTypes,
    this.maxFileSize,
    this.maxFileCount,
    this.minLength,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.onlyIntegerValue,
    this.onlyFutureDate,
    this.onlyPastDate,
  });

  factory PollQuestionEntity.fromJson(Map<String, dynamic> json) =>
      _$PollQuestionEntityFromJson(json);
  Map<String, dynamic> toJson() => _$PollQuestionEntityToJson(this);
}

@JsonSerializable()
class PollAnswerEntity extends ApiEntity {
  final String questionId;

  // fields for storing the answer
  final String? text;
  final double? number;
  final DateTime? date;
  final List<MediaEntity>? files;
  final List<String>? choices;
  final int? rating;

  PollAnswerEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.questionId,
    this.text,
    this.number,
    this.date,
    this.files,
    this.choices,
    this.rating,
  });

  factory PollAnswerEntity.fromJson(Map<String, dynamic> json) =>
      _$PollAnswerEntityFromJson(json);
  Map<String, dynamic> toJson() => _$PollAnswerEntityToJson(this);
}
