import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/entities/subject.dart';
import 'package:mobile_2/core/types/api_entity.dart';
import 'package:mobile_2/core/types/richtext.dart';

part 'work.g.dart';

enum WorkType { test, miniTest, phrase, secondPart, trialWork }

enum WorkTaskType { word, text, essay, finalEssay, dictation }

enum TaskCheckingStrategy { type1, type2, type3, type4 }

@JsonSerializable()
class WorkEntity extends ApiEntity {
  final String slug;
  final String name;
  final WorkType type;
  final String? description;
  final SubjectEntity? subject;
  final String? subjectId;
  final List<WorkTaskEntity>? tasks;

  WorkEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.slug,
    required this.name,
    required this.type,
    this.description,
    this.subject,
    this.subjectId,
    this.tasks,
  });

  factory WorkEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkEntityFromJson(json);
  Map<String, dynamic> toJson() => _$WorkEntityToJson(this);
}

@JsonSerializable()
class WorkTaskEntity extends ApiEntity {
  final String workId;
  final WorkTaskType type;
  @JsonKey(fromJson: RichText.fromJson, toJson: _richTextToJson)
  final RichText? content;
  @JsonKey(fromJson: RichText.fromJson, toJson: _richTextToJson)
  final RichText? checkHint;
  @JsonKey(fromJson: RichText.fromJson, toJson: _richTextToJson)
  final RichText? solveHint;
  final String? rightAnswer;
  final int highestScore;
  final int order;
  final bool isAnswerVisibleBeforeCheck;
  final bool isCheckOneByOneEnabled;
  final TaskCheckingStrategy? checkingStrategy;

  WorkTaskEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.workId,
    required this.type,
    this.content,
    required this.highestScore,
    required this.order,
    this.checkHint,
    this.solveHint,
    this.rightAnswer,
    this.checkingStrategy,
    this.isAnswerVisibleBeforeCheck = false,
    this.isCheckOneByOneEnabled = false,
  });

  factory WorkTaskEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkTaskEntityFromJson(json);
  Map<String, dynamic> toJson() => _$WorkTaskEntityToJson(this);
}

Map<String, dynamic>? _richTextToJson(RichText? r) => r?.toJson();
