import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/api/color_converter.dart';
import 'package:mobile_2/core/types/api_entity.dart';

part 'subject.g.dart';

@JsonSerializable()
class SubjectEntity extends ApiEntity {
  final String name;
  @ColorHexConverter()
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
