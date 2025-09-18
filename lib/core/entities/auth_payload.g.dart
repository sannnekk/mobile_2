// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthPayload _$AuthPayloadFromJson(Map<String, dynamic> json) => AuthPayload(
  userId: json['userId'] as String,
  username: json['username'] as String,
  role: UserEntity.userRoleFromJson(json['role'] as String),
);

Map<String, dynamic> _$AuthPayloadToJson(AuthPayload instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'role': UserEntity.userRoleToJson(instance.role),
    };
