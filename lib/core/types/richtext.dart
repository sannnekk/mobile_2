import 'package:flutter_quill/quill_delta.dart';

class RichText {
  final Delta _delta;

  RichText._(this._delta);

  factory RichText.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RichText._(Delta());
    }

    final ops = json['ops'];
    final delta = ops != null ? Delta.fromJson(ops as List) : Delta();
    return RichText._(delta);
  }

  Map<String, dynamic> toJson() {
    return {'ops': _delta.toJson()};
  }

  Delta get delta {
    if (!(_delta.last.data as String).endsWith('\n')) {
      _delta.insert('\n');
    }

    return _delta;
  }

  factory RichText.fromDelta(Delta delta) {
    return RichText._(delta);
  }

  bool isEmpty() {
    return _delta.isEmpty || (_delta.length == 1 && _delta.first.data == '\n');
  }
}
