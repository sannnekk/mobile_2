import 'package:json_annotation/json_annotation.dart';
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
  @JsonKey(fromJson: RichText.fromJson, toJson: _richTextToJson)
  final RichText? description;
  final MediaEntity? thumbnail;
  final String? url;
  final int sizeInBytes;
  final VideoServiceType serviceType;
  final VideoState state;
  final String uniqueIdentifier;
  final int duration;
  final UserEntity uploadedBy;
  final String? uploadUrl;
  final DateTime? publishedAt;
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
    this.sizeInBytes = 0,
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
}

Map<String, dynamic>? _richTextToJson(RichText? r) => r?.toJson();
