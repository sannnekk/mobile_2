// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  name: json['name'] as String,
  email: json['email'] as String,
  role: userRoleFromJson(json['role'] as String),
  username: json['username'] as String,
  telegramUsername: json['telegramUsername'] as String?,
  telegramId: json['telegramId'] as String?,
  telegramNotificationsEnabled:
      json['telegramNotificationsEnabled'] as bool? ?? false,
  isBlocked: json['isBlocked'] as bool? ?? false,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'name': instance.name,
      'email': instance.email,
      'role': userRoleToJson(instance.role),
      'username': instance.username,
      'telegramUsername': instance.telegramUsername,
      'telegramId': instance.telegramId,
      'telegramNotificationsEnabled': instance.telegramNotificationsEnabled,
      'isBlocked': instance.isBlocked,
    };

UserAvatarEntity _$UserAvatarEntityFromJson(Map<String, dynamic> json) =>
    UserAvatarEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: json['media'] == null
          ? null
          : MediaEntity.fromJson(json['media'] as Map<String, dynamic>),
      avatarType: avatarTypeFromJson(json['avatarType'] as String),
      telegramAvatarUrl: json['telegramAvatarUrl'] as String? ?? '',
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserAvatarEntityToJson(UserAvatarEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'media': instance.media,
      'avatarType': avatarTypeToJson(instance.avatarType),
      'telegramAvatarUrl': instance.telegramAvatarUrl,
    };

MentorAssignmentEntity _$MentorAssignmentEntityFromJson(
  Map<String, dynamic> json,
) => MentorAssignmentEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  mentorId: json['mentorId'] as String,
  mentor: json['mentor'] == null
      ? null
      : UserEntity.fromJson(json['mentor'] as Map<String, dynamic>),
  studentId: json['studentId'] as String,
  student: json['student'] == null
      ? null
      : UserEntity.fromJson(json['student'] as Map<String, dynamic>),
  subjectId: json['subjectId'] as String,
  subject: json['subject'] == null
      ? null
      : SubjectEntity.fromJson(json['subject'] as Map<String, dynamic>),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MentorAssignmentEntityToJson(
  MentorAssignmentEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'mentorId': instance.mentorId,
  'mentor': instance.mentor,
  'studentId': instance.studentId,
  'student': instance.student,
  'subjectId': instance.subjectId,
  'subject': instance.subject,
};
