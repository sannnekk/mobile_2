import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/styles/colors.dart';

class ColorHexConverter implements JsonConverter<Color, String> {
  const ColorHexConverter();

  @override
  Color fromJson(String json) {
    if (json.startsWith('#')) {
      json = json.substring(1);
    }
    if (json.startsWith('var(')) {
      return cssVarToColor(json);
    }
    if (json.length == 6) {
      json = 'ff$json'; // Add full opacity if alpha is missing
    }
    final intColor = int.parse(json, radix: 16);
    return Color(intColor);
  }

  @override
  String toJson(Color object) =>
      '#${object.toARGB32().toRadixString(16).padLeft(8, '0')}';

  Color cssVarToColor(String cssVar) {
    // Example input: var(--primary-color)
    final varName = cssVar.substring(4, cssVar.length - 1).trim();
    // Map CSS variable names to actual colors
    switch (varName) {
      case '--primary':
        return AppColors.primary;
      case '--secondary':
        return AppColors.secondary;
      case '--success':
        return AppColors.success;
      case '--warning':
        return AppColors.warning;
      case '--danger':
        return AppColors.danger;
      default:
        return AppColors.black;
    }
  }
}
