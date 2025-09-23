import 'package:json_annotation/json_annotation.dart';

part 'media.g.dart';

@JsonSerializable()
class MediaEntity {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String src;
  final String name;
  final String? type;
  final int order;

  MediaEntity({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.src,
    required this.name,
    this.type,
    this.order = 0,
  });

  factory MediaEntity.fromJson(Map<String, dynamic> json) =>
      _$MediaEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MediaEntityToJson(this);
}
