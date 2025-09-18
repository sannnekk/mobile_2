import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/types/richtext.dart';

class RichTextConverter
    implements JsonConverter<RichText?, Map<String, dynamic>?> {
  const RichTextConverter();

  @override
  RichText? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return RichText.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(RichText? object) {
    if (object == null || object.isEmpty()) return null;
    return object.toJson();
  }
}
