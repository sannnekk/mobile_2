import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:mobile_2/core/types/richtext.dart' as rt;
import 'package:mobile_2/widgets/shared/noo_text.dart';

class NooWordCounter extends StatelessWidget {
  final rt.RichText richText;
  final int maxCount;
  final int minCount;

  const NooWordCounter({
    super.key,
    required this.richText,
    required this.maxCount,
    required this.minCount,
  });

  @override
  Widget build(BuildContext context) {
    final wordCount = _countWords(richText);

    return NooText(
      'Количество слов: $wordCount, '
      'минимум: $minCount, максимум: $maxCount',
    );
  }

  int _countWords(rt.RichText richText) {
    final text = _toText(richText.delta);
    return _wordCounter(text);
  }

  String _toText(Delta delta) {
    String result = '';
    for (final op in delta.toList()) {
      if (op.data is String) {
        result += op.data as String;
      }
    }
    return result;
  }

  int _wordCounter(String text) {
    final cleaned = text
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'[.,/#!$%^&*;:{}=\-_`~()]'), '');
    final words = cleaned
        .split(' ')
        .where((word) => word.isNotEmpty && double.tryParse(word) == null)
        .toList();
    return words.length;
  }
}
