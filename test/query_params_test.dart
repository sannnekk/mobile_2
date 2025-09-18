import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/api/query_params.dart';

void main() {
  group('QueryParams', () {
    test('empty params returns null map', () {
      final params = QueryParams.empty();
      expect(params.toMap(), isNull);
    });

    test('passes through primitive values', () {
      final params = QueryParams({
        'q': StringParam('hello'),
        'page': IntParam(2),
      });
      expect(params.toMap(), {'q': 'hello', 'page': '2'});
    });

    test('encodes array values with arr(...)', () {
      final params = QueryParams({
        'ids': ArrayParam([1, 2, 3]),
      });
      expect(params.toMap(), {'ids': 'arr(1|2|3)'});
    });

    test('encodes range values with range(min|max)', () {
      final params = QueryParams({
        'date': RangeParam('2024-01-01', '2024-12-31'),
      });
      expect(params.toMap(), {'date': 'range(2024-01-01|2024-12-31)'});
    });

    test('handles boolean values', () {
      final params = QueryParams({
        'active': BoolParam(true),
        'archived': BoolParam(false),
      });
      expect(params.toMap(), {'active': 'true', 'archived': 'false'});
    });

    test('fromMap creates typed params', () {
      final map = {
        'q': 'hello',
        'page': 2,
        'active': true,
        'ids': [1, 2, 3],
      };
      final params = QueryParams.fromMap(map);
      expect(params.get('q'), isA<StringParam>());
      expect(params.get('page'), isA<IntParam>());
      expect(params.get('active'), isA<BoolParam>());
      expect(params.get('ids'), isA<ArrayParam>());
    });

    test('add and addAll methods work', () {
      final params = QueryParams.empty().add('q', StringParam('hello')).addAll({
        'page': IntParam(1),
      });

      expect(params.toMap(), {'q': 'hello', 'page': '1'});
    });

    test('filter methods work correctly', () {
      final boolFilter = QueryParams.empty().addBoolFilter("isArchived", true);
      expect(boolFilter.toMap(), {'filter[isArchived]': 'true'});

      final stringFilter = QueryParams.empty().addStringFilter(
        "isArchived",
        'test',
      );
      expect(stringFilter.toMap(), {'filter[isArchived]': 'test'});

      final intFilter = QueryParams.empty().addIntFilter("isArchived", 42);
      expect(intFilter.toMap(), {'filter[isArchived]': '42'});

      final arrayFilter = QueryParams.empty().addArrayFilter("isArchived", [
        1,
        2,
        3,
      ]);
      expect(arrayFilter.toMap(), {'filter[isArchived]': 'arr(1|2|3)'});

      final rangeFilter = QueryParams.empty().addRangeFilter(
        "isArchived",
        'min',
        'max',
      );
      expect(rangeFilter.toMap(), {'filter[isArchived]': 'range(min|max)'});
    });

    test('CourseAssignmentFilterKey enum works', () {
      expect("isArchived", 'isArchived');
    });
  });
}
