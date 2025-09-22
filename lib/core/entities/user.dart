import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/entities/enum_helpers.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/core/entities/subject.dart';
import 'package:mobile_2/core/types/api_entity.dart';

part 'user.g.dart';

enum UserRole { student, mentor, assistant, teacher, admin }

enum AvatarType { custom, telegram }

@JsonSerializable()
class UserEntity extends ApiEntity {
  final String name;
  final String email;
  @JsonKey(fromJson: userRoleFromJson, toJson: userRoleToJson)
  final UserRole role;
  final String username;
  final String? telegramUsername;
  final String? telegramId;
  final bool telegramNotificationsEnabled;
  final bool isBlocked;
  final UserAvatarEntity? avatar;
  final List<MentorAssignmentEntity> mentorAssignmentsAsStudent;
  final List<MentorAssignmentEntity> mentorAssignmentsAsMentor;

  UserEntity({
    required super.id,
    required super.createdAt,
    required this.name,
    required this.email,
    required this.role,
    required this.username,
    this.telegramUsername,
    this.telegramId,
    this.telegramNotificationsEnabled = false,
    this.isBlocked = false,
    this.avatar,
    super.updatedAt,
    this.mentorAssignmentsAsStudent = const [],
    this.mentorAssignmentsAsMentor = const [],
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  static UserRole userRoleFromJson(String json) {
    final camel = kebabToCamel(json);
    return UserRole.values.firstWhere((e) => e.name == camel);
  }

  static String userRoleToJson(UserRole role) => camelToKebab(role.name);
}

@JsonSerializable()
class UserAvatarEntity extends ApiEntity {
  final MediaEntity? media;
  @JsonKey(fromJson: avatarTypeFromJson, toJson: avatarTypeToJson)
  final AvatarType avatarType;

  final String telegramAvatarUrl;

  UserAvatarEntity({
    required super.id,
    required super.createdAt,
    this.media,
    required this.avatarType,
    this.telegramAvatarUrl = '',
    super.updatedAt,
  });

  factory UserAvatarEntity.fromJson(Map<String, dynamic> json) =>
      _$UserAvatarEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserAvatarEntityToJson(this);

  static AvatarType avatarTypeFromJson(String json) =>
      enumFromString(AvatarType.values, json);

  static String avatarTypeToJson(AvatarType type) => enumToString(type);
}

@JsonSerializable()
class MentorAssignmentEntity extends ApiEntity {
  final String? mentorId;
  final UserEntity? mentor;
  final String? studentId;
  final UserEntity? student;
  final String? subjectId;
  final SubjectEntity? subject;

  MentorAssignmentEntity({
    required super.id,
    required super.createdAt,
    this.mentorId,
    this.mentor,
    this.studentId,
    this.student,
    this.subjectId,
    this.subject,
    super.updatedAt,
  });
  factory MentorAssignmentEntity.fromJson(Map<String, dynamic> json) =>
      _$MentorAssignmentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MentorAssignmentEntityToJson(this);
}
