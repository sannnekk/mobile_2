import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/api/query_params.dart';

void main() {
  group('QueryParams.flatten', () {
    test('returns null when input is null', () {
      expect(QueryParams.flatten(null), isNull);
    });

    test('passes through primitive values', () {
      final out = QueryParams.flatten({'q': 'hello', 'page': 2});
      expect(out, {'q': 'hello', 'page': 2});
    });

    test('encodes array values with arr(...)', () {
      final out = QueryParams.flatten({
        'ids': [1, 2, 3],
      });
      expect(out, {'ids': 'arr(1|2|3)'});
    });

    test('encodes range values with range(min|max)', () {
      final out = QueryParams.flatten({
        'date': {'min': '2024-01-01', 'max': '2024-12-31'},
      });
      expect(out, {'date': 'range(2024-01-01|2024-12-31)'});
    });

    test('ignores nulls', () {
      final out = QueryParams.flatten({'q': null, 'x': 1});
      expect(out, {'x': 1});
    });
  });
}
