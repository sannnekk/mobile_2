import 'dart:convert';
import 'package:flutter_quill/quill_delta.dart';

class RichText {
  final Delta _delta;

  static const supportedAttributes = [
    'bold',
    'italic',
    'underline',
    'strike',
    'subscript',
    'superscript',
    'link',
    'header',
    'list_bullet',
    'list_ordered',
    'list_checked',
    'align',
    //'table': TableAttribute, // TODO: Add support for tables
    //'comment': null,
    //'image-comment': null,
    //'color',
  ];

  static const supportedEmbedTypes = ['image', 'video'];

  RichText._(this._delta);

  factory RichText.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RichText._(Delta()..insert('\n'));
    }

    final ops = json['ops'];
    final delta = ops != null ? Delta.fromJson(ops as List) : Delta();
    return RichText._(sanitize(delta));
  }

  Map<String, dynamic> toJson() {
    return {'ops': _delta.toJson()};
  }

  Delta get delta => _delta;

  factory RichText.fromDelta(Delta delta) {
    return RichText._(sanitize(delta));
  }

  bool isEmpty() {
    return _delta.isEmpty || (_delta.length == 1 && _delta.first.data == '\n');
  }

  static Delta sanitize(Delta delta) {
    final sanitized = Delta();

    // Only consider insert operations when building a document delta
    for (final op in delta.toList()) {
      if (!op.isInsert) continue;

      final attrs = _filterSupportedAttributes(op.attributes);

      // Text insert
      if (op.data is String) {
        sanitized.insert(op.data as String, attrs);
        continue;
      }

      // Embed insert
      if (op.data is Map<String, dynamic>) {
        final data = op.data as Map<String, dynamic>;
        if (data.isEmpty) continue;
        final embedType = data.keys.first;
        if (supportedEmbedTypes.contains(embedType)) {
          sanitized.insert({embedType: data[embedType]}, attrs);
        }
      }
    }

    // Ensure the document ends with a newline (Quill invariant)
    if (sanitized.isEmpty) {
      sanitized.insert('\n');
    } else {
      final last = sanitized.last;
      if (last.data is String) {
        final str = last.data as String;
        if (!str.endsWith('\n')) {
          sanitized.insert('\n');
        }
      } else {
        // Last op is an embed – append a newline
        sanitized.insert('\n');
      }
    }

    // If sanitization didn't change the delta content, return the original
    try {
      final originalJson = jsonEncode(delta.toJson());
      final sanitizedJson = jsonEncode(sanitized.toJson());
      if (originalJson == sanitizedJson) {
        return delta;
      }
    } catch (_) {
      // Fallback to returning sanitized when comparison fails
    }

    return sanitized;
  }

  static Map<String, dynamic>? _filterSupportedAttributes(
    Map<String, dynamic>? attributes,
  ) {
    if (attributes == null || attributes.isEmpty) return null;
    final filtered = <String, dynamic>{};
    attributes.forEach((key, value) {
      if (supportedAttributes.contains(key)) {
        filtered[key] = value;
      }
    });
    return filtered.isEmpty ? null : filtered;
  }
}
