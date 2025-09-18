import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

class ColorHexConverter implements JsonConverter<Color, String> {
  const ColorHexConverter();

  @override
  Color fromJson(String json) =>
      Color(int.parse(json.replaceFirst('#', '0xff')));

  @override
  String toJson(Color object) =>
      '#${object.toARGB32().toRadixString(16).padLeft(8, '0')}';
}
