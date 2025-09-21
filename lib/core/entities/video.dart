import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/api/richtext_converter.dart';
import 'package:mobile_2/core/entities/enum_helpers.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/types/api_entity.dart';
import 'package:mobile_2/core/types/richtext.dart';

part 'video.g.dart';

enum VideoServiceType { yandex }

enum VideoState { notUploaded, uploaded, uploading, failed }

enum VideoAccessType { everyone, courseId, mentorId, role }

@JsonSerializable()
class VideoEntity extends ApiEntity {
  final String title;
  @RichTextConverter()
  final RichText? description;
  final MediaEntity? thumbnail;
  final String? url;
  @JsonKey(fromJson: videoServiceTypeFromJson, toJson: videoServiceTypeToJson)
  final VideoServiceType serviceType;
  final VideoState state;
  final String uniqueIdentifier;
  final int duration;
  final UserEntity uploadedBy;
  final String? uploadUrl;
  final DateTime? publishedAt;
  @JsonKey(fromJson: videoAccessTypeFromJson, toJson: videoAccessTypeToJson)
  final VideoAccessType accessType;
  final String? accessValue;
  final Map<String, int> reactionCounts;
  final String? myReaction;

  VideoEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.title,
    this.description,
    this.thumbnail,
    this.url,
    this.serviceType = VideoServiceType.yandex,
    this.state = VideoState.notUploaded,
    this.uniqueIdentifier = '',
    this.duration = 0,
    required this.uploadedBy,
    this.uploadUrl,
    this.publishedAt,
    this.accessType = VideoAccessType.everyone,
    this.accessValue,
    this.reactionCounts = const {},
    this.myReaction,
  });

  factory VideoEntity.fromJson(Map<String, dynamic> json) =>
      _$VideoEntityFromJson(json);

  Map<String, dynamic> toJson() => _$VideoEntityToJson(this);

  static VideoServiceType videoServiceTypeFromJson(String json) =>
      enumFromString(VideoServiceType.values, json);

  static String videoServiceTypeToJson(VideoServiceType type) =>
      enumToString(type);
  static VideoAccessType videoAccessTypeFromJson(String json) =>
      enumFromString(VideoAccessType.values, json);

  static String videoAccessTypeToJson(VideoAccessType type) =>
      enumToString(type);
}
