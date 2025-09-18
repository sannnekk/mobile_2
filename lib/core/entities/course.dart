import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/api/color_converter.dart';
import 'package:mobile_2/core/api/richtext_converter.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/core/entities/poll.dart';
import 'package:mobile_2/core/entities/subject.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/entities/video.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/types/api_entity.dart';
import 'package:mobile_2/core/types/richtext.dart';

part 'course.g.dart';

@JsonSerializable()
class CourseEntity extends ApiEntity {
  final String slug;
  final String name;
  final List<MediaEntity> images;
  final List<UserEntity>? authors;
  final List<UserEntity>? editors;
  final String? description;
  final List<CourseChapterEntity>? chapters;
  final SubjectEntity? subject;
  final String? subjectId;
  final int? studentCount;

  CourseEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.slug,
    required this.name,
    this.description,
    this.images = const [],
    this.authors,
    this.editors,
    this.chapters,
    this.subject,
    this.subjectId,
    this.studentCount,
  });

  factory CourseEntity.fromJson(Map<String, dynamic> json) =>
      _$CourseEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CourseEntityToJson(this);
}

@JsonSerializable()
class CourseChapterEntity extends ApiEntity {
  final String name;
  @ColorHexConverter()
  final Color? titleColor;
  final List<CourseChapterEntity> chapters;
  final List<CourseMaterialEntity> materials;
  final int order;
  final bool isActive;
  final bool isPinned;

  CourseChapterEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.name,
    this.titleColor,
    this.chapters = const [],
    this.materials = const [],
    this.order = 0,
    this.isActive = true,
    this.isPinned = false,
  });

  factory CourseChapterEntity.fromJson(Map<String, dynamic> json) =>
      _$CourseChapterEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CourseChapterEntityToJson(this);
}

@JsonSerializable()
class CourseMaterialEntity extends ApiEntity {
  final String name;
  final String? description;
  @RichTextConverter()
  final RichText? content;
  final int order;
  final String? workId;
  final bool isActive;
  final DateTime? activateAt;
  final WorkEntity? work;
  final DateTime? workSolveDeadline;
  final DateTime? workCheckDeadline;
  final PollEntity? poll;
  final String? pollId;
  final List<VideoEntity>? videos;
  final bool isWorkAvailable;
  final bool isPinned;
  @ColorHexConverter()
  final Color? titleColor;
  final List<MediaEntity> files;
  final String? myReaction;

  CourseMaterialEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.name,
    this.description,
    this.content,
    this.order = 0,
    this.workId,
    this.isActive = true,
    this.activateAt,
    this.work,
    this.workSolveDeadline,
    this.workCheckDeadline,
    this.poll,
    this.pollId,
    this.videos,
    this.isWorkAvailable = false,
    this.isPinned = false,
    this.titleColor,
    this.files = const [],
    this.myReaction,
  });

  factory CourseMaterialEntity.fromJson(Map<String, dynamic> json) =>
      _$CourseMaterialEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CourseMaterialEntityToJson(this);
}

@JsonSerializable()
class CourseAssignmentEntity extends ApiEntity {
  final String courseId;
  final CourseEntity? course;
  final String studentId;
  final UserEntity? student;
  final String? assignerId;
  final UserEntity? assigner;
  final bool isArchived;
  final bool isPinned;

  CourseAssignmentEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.courseId,
    this.course,
    required this.studentId,
    this.student,
    this.assignerId,
    this.assigner,
    this.isArchived = false,
    this.isPinned = false,
  });

  factory CourseAssignmentEntity.fromJson(Map<String, dynamic> json) =>
      _$CourseAssignmentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CourseAssignmentEntityToJson(this);
}
