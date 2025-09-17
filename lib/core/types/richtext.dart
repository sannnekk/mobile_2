import 'package:flutter_quill/quill_delta.dart';

class RichText {
  final Delta _delta;

  RichText._(this._delta);

  factory RichText.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RichText._(Delta());
    }

    final delta = Delta.fromJson(json['ops'] as List);
    return RichText._(delta);
  }

  Map<String, dynamic> toJson() {
    return {'ops': _delta.toJson()};
  }

  Delta get delta => _delta;

  factory RichText.fromPlain(String text) {
    return RichText._(Delta()..insert(text));
  }
}
