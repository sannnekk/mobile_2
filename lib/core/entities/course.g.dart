// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseEntity _$CourseEntityFromJson(Map<String, dynamic> json) => CourseEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  slug: json['slug'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => MediaEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  authors: (json['authors'] as List<dynamic>?)
      ?.map((e) => UserEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  editors: (json['editors'] as List<dynamic>?)
      ?.map((e) => UserEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  chapters: (json['chapters'] as List<dynamic>?)
      ?.map((e) => CourseChapterEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  subject: json['subject'] == null
      ? null
      : SubjectEntity.fromJson(json['subject'] as Map<String, dynamic>),
  subjectId: json['subjectId'] as String?,
  studentCount: (json['studentCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$CourseEntityToJson(CourseEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'slug': instance.slug,
      'name': instance.name,
      'images': instance.images,
      'authors': instance.authors,
      'editors': instance.editors,
      'description': instance.description,
      'chapters': instance.chapters,
      'subject': instance.subject,
      'subjectId': instance.subjectId,
      'studentCount': instance.studentCount,
    };

CourseChapterEntity _$CourseChapterEntityFromJson(
  Map<String, dynamic> json,
) => CourseChapterEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  name: json['name'] as String,
  titleColor: _$JsonConverterFromJson<String, Color>(
    json['titleColor'],
    const ColorHexConverter().fromJson,
  ),
  chapters:
      (json['chapters'] as List<dynamic>?)
          ?.map((e) => CourseChapterEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  materials:
      (json['materials'] as List<dynamic>?)
          ?.map((e) => CourseMaterialEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  order: (json['order'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  isPinned: json['isPinned'] as bool? ?? false,
);

Map<String, dynamic> _$CourseChapterEntityToJson(
  CourseChapterEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'name': instance.name,
  'titleColor': _$JsonConverterToJson<String, Color>(
    instance.titleColor,
    const ColorHexConverter().toJson,
  ),
  'chapters': instance.chapters,
  'materials': instance.materials,
  'order': instance.order,
  'isActive': instance.isActive,
  'isPinned': instance.isPinned,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

CourseMaterialEntity _$CourseMaterialEntityFromJson(
  Map<String, dynamic> json,
) => CourseMaterialEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  name: json['name'] as String,
  description: json['description'] as String?,
  content: const RichTextConverter().fromJson(
    json['content'] as Map<String, dynamic>?,
  ),
  order: (json['order'] as num?)?.toInt() ?? 0,
  workId: json['workId'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  activateAt: json['activateAt'] == null
      ? null
      : DateTime.parse(json['activateAt'] as String),
  work: json['work'] == null
      ? null
      : WorkEntity.fromJson(json['work'] as Map<String, dynamic>),
  workSolveDeadline: json['workSolveDeadline'] == null
      ? null
      : DateTime.parse(json['workSolveDeadline'] as String),
  workCheckDeadline: json['workCheckDeadline'] == null
      ? null
      : DateTime.parse(json['workCheckDeadline'] as String),
  poll: json['poll'] == null
      ? null
      : PollEntity.fromJson(json['poll'] as Map<String, dynamic>),
  pollId: json['pollId'] as String?,
  videos: (json['videos'] as List<dynamic>?)
      ?.map((e) => VideoEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  isWorkAvailable: json['isWorkAvailable'] as bool? ?? false,
  isPinned: json['isPinned'] as bool? ?? false,
  titleColor: _$JsonConverterFromJson<String, Color>(
    json['titleColor'],
    const ColorHexConverter().fromJson,
  ),
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => MediaEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  myReaction: json['myReaction'] as String?,
);

Map<String, dynamic> _$CourseMaterialEntityToJson(
  CourseMaterialEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'name': instance.name,
  'description': instance.description,
  'content': const RichTextConverter().toJson(instance.content),
  'order': instance.order,
  'workId': instance.workId,
  'isActive': instance.isActive,
  'activateAt': instance.activateAt?.toIso8601String(),
  'work': instance.work,
  'workSolveDeadline': instance.workSolveDeadline?.toIso8601String(),
  'workCheckDeadline': instance.workCheckDeadline?.toIso8601String(),
  'poll': instance.poll,
  'pollId': instance.pollId,
  'videos': instance.videos,
  'isWorkAvailable': instance.isWorkAvailable,
  'isPinned': instance.isPinned,
  'titleColor': _$JsonConverterToJson<String, Color>(
    instance.titleColor,
    const ColorHexConverter().toJson,
  ),
  'files': instance.files,
  'myReaction': instance.myReaction,
};

CourseAssignmentEntity _$CourseAssignmentEntityFromJson(
  Map<String, dynamic> json,
) => CourseAssignmentEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  courseId: json['courseId'] as String,
  course: json['course'] == null
      ? null
      : CourseEntity.fromJson(json['course'] as Map<String, dynamic>),
  studentId: json['studentId'] as String,
  student: json['student'] == null
      ? null
      : UserEntity.fromJson(json['student'] as Map<String, dynamic>),
  assignerId: json['assignerId'] as String?,
  assigner: json['assigner'] == null
      ? null
      : UserEntity.fromJson(json['assigner'] as Map<String, dynamic>),
  isArchived: json['isArchived'] as bool? ?? false,
  isPinned: json['isPinned'] as bool? ?? false,
);

Map<String, dynamic> _$CourseAssignmentEntityToJson(
  CourseAssignmentEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'courseId': instance.courseId,
  'course': instance.course,
  'studentId': instance.studentId,
  'student': instance.student,
  'assignerId': instance.assignerId,
  'assigner': instance.assigner,
  'isArchived': instance.isArchived,
  'isPinned': instance.isPinned,
};
