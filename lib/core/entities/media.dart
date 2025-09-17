import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/types/api_entity.dart';

part 'media.g.dart';

@JsonSerializable()
class MediaEntity extends ApiEntity {
  final String src;
  final String name;
  final String? type;
  final int order;

  MediaEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.src,
    required this.name,
    this.type,
    this.order = 0,
  });

  factory MediaEntity.fromJson(Map<String, dynamic> json) =>
      _$MediaEntityFromJson(json);
  Map<String, dynamic> toJson() => _$MediaEntityToJson(this);
}
