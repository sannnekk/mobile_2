import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/entities/work.dart';

void main() {
  group('WorkEntity', () {
    test('fromJson handles kebab-case WorkType correctly', () {
      final json = {
        'id': 'work1',
        'createdAt': '2023-01-01T00:00:00.000Z',
        'slug': 'test-work',
        'name': 'Test Work',
        'type': 'trial-work', // kebab-case from server
      };

      final work = WorkEntity.fromJson(json);

      expect(work.type, WorkType.trialWork);
      expect(work.slug, 'test-work');
      expect(work.name, 'Test Work');
    });

    test('fromJson handles all kebab-case WorkTypes', () {
      final testCases = [
        {'json': 'test', 'expected': WorkType.test},
        {'json': 'mini-test', 'expected': WorkType.miniTest},
        {'json': 'phrase', 'expected': WorkType.phrase},
        {'json': 'second-part', 'expected': WorkType.secondPart},
        {'json': 'trial-work', 'expected': WorkType.trialWork},
      ];

      for (final testCase in testCases) {
        final json = {
          'id': 'work1',
          'createdAt': '2023-01-01T00:00:00.000Z',
          'slug': 'test-work',
          'name': 'Test Work',
          'type': testCase['json'] as String,
        };

        final work = WorkEntity.fromJson(json);
        expect(
          work.type,
          testCase['expected'],
          reason: 'Failed for ${testCase['json']}',
        );
      }
    });

    test('toJson converts WorkType back to kebab-case', () {
      final work = WorkEntity(
        id: 'work1',
        createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        slug: 'test-work',
        name: 'Test Work',
        type: WorkType.trialWork,
      );

      final json = work.toJson();

      expect(json['type'], 'trial-work');
    });
  });
}
