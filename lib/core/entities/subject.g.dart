// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectEntity _$SubjectEntityFromJson(Map<String, dynamic> json) =>
    SubjectEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      name: json['name'] as String,
      color: const ColorHexConverter().fromJson(json['color'] as String),
    );

Map<String, dynamic> _$SubjectEntityToJson(SubjectEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'name': instance.name,
      'color': const ColorHexConverter().toJson(instance.color),
    };
