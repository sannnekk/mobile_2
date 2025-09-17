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
    super.updatedAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UserEntityToJson(this);
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
}

@JsonSerializable()
class MentorAssignmentEntity extends ApiEntity {
  final String mentorId;
  final UserEntity? mentor;
  final String studentId;
  final UserEntity? student;
  final String subjectId;
  final SubjectEntity? subject;

  MentorAssignmentEntity({
    required super.id,
    required super.createdAt,
    required this.mentorId,
    this.mentor,
    required this.studentId,
    this.student,
    required this.subjectId,
    this.subject,
    super.updatedAt,
  });
  factory MentorAssignmentEntity.fromJson(Map<String, dynamic> json) =>
      _$MentorAssignmentEntityFromJson(json);
  Map<String, dynamic> toJson() => _$MentorAssignmentEntityToJson(this);
}
