import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/types/api_entity.dart';

part 'subject.g.dart';

class _ColorHexConverter implements JsonConverter<Color, String> {
  const _ColorHexConverter();
  @override
  Color fromJson(String json) =>
      Color(int.parse(json.replaceFirst('#', '0xff')));
  @override
  String toJson(Color object) =>
      '#${object.value.toRadixString(16).padLeft(8, '0')}';
}

@JsonSerializable()
class SubjectEntity extends ApiEntity {
  final String name;
  @_ColorHexConverter()
  final Color color;

  SubjectEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.name,
    required this.color,
  });

  factory SubjectEntity.fromJson(Map<String, dynamic> json) =>
      _$SubjectEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectEntityToJson(this);
}
