// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoEntity _$VideoEntityFromJson(Map<String, dynamic> json) => VideoEntity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  title: json['title'] as String,
  description: const RichTextConverter().fromJson(
    json['description'] as Map<String, dynamic>?,
  ),
  thumbnail: json['thumbnail'] == null
      ? null
      : MediaEntity.fromJson(json['thumbnail'] as Map<String, dynamic>),
  url: json['url'] as String?,
  serviceType: json['serviceType'] == null
      ? VideoServiceType.yandex
      : VideoEntity.videoServiceTypeFromJson(json['serviceType'] as String),
  state:
      $enumDecodeNullable(_$VideoStateEnumMap, json['state']) ??
      VideoState.notUploaded,
  uniqueIdentifier: json['uniqueIdentifier'] as String? ?? '',
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  uploadedBy: json['uploadedBy'] == null
      ? null
      : UserEntity.fromJson(json['uploadedBy'] as Map<String, dynamic>),
  uploadUrl: json['uploadUrl'] as String?,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  accessType: json['accessType'] == null
      ? VideoAccessType.everyone
      : VideoEntity.videoAccessTypeFromJson(json['accessType'] as String),
  accessValue: json['accessValue'] as String?,
  reactionCounts:
      (json['reactionCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  myReaction: json['myReaction'] as String?,
);

Map<String, dynamic> _$VideoEntityToJson(VideoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'title': instance.title,
      'description': const RichTextConverter().toJson(instance.description),
      'thumbnail': instance.thumbnail,
      'url': instance.url,
      'serviceType': VideoEntity.videoServiceTypeToJson(instance.serviceType),
      'state': _$VideoStateEnumMap[instance.state]!,
      'uniqueIdentifier': instance.uniqueIdentifier,
      'duration': instance.duration,
      'uploadedBy': instance.uploadedBy,
      'uploadUrl': instance.uploadUrl,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'accessType': VideoEntity.videoAccessTypeToJson(instance.accessType),
      'accessValue': instance.accessValue,
      'reactionCounts': instance.reactionCounts,
      'myReaction': instance.myReaction,
    };

const _$VideoStateEnumMap = {
  VideoState.notUploaded: 'notUploaded',
  VideoState.uploaded: 'uploaded',
  VideoState.uploading: 'uploading',
  VideoState.failed: 'failed',
  VideoState.published: 'published',
};
