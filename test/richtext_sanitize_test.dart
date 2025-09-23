import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:mobile_2/core/types/richtext.dart' as rt;

void main() {
  group('RichText.sanitize', () {
    test('keeps supported embeds without duplication and ensures newline', () {
      final original = Delta()
        ..insert({'image': 'https://example.com/a.png'})
        ..insert('\n');

      final first = rt.RichText.fromDelta(original).delta;
      expect(first.toList().length, 2);

      // Re-run sanitize on its own output should be idempotent
      final second = rt.RichText.fromDelta(first).delta;
      expect(second.toJson(), first.toJson());

      // Typing text before should not duplicate image embeds
      final withText = Delta()
        ..insert('a')
        ..insert({'image': 'https://example.com/a.png'})
        ..insert('\n');
      final sanitized = rt.RichText.fromDelta(withText).delta;

      // Expect exactly one image embed op and trailing newline
      final ops = sanitized.toList();
      final images = ops.where(
        (op) => op.data is Map && (op.data as Map).containsKey('image'),
      );
      expect(images.length, 1);
      expect(ops.last.data, '\n');
    });

    test('filters unsupported attributes and preserves supported', () {
      final original = Delta()
        ..insert('Hello', {'bold': true, 'foo': 'bar'})
        ..insert('\n');

      final sanitized = rt.RichText.fromDelta(original).delta;
      final attrs = sanitized.toList().first.attributes!;
      expect(attrs['bold'], true);
      expect(attrs.containsKey('foo'), false);
    });
  });
}
