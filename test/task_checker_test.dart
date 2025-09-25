import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/types/richtext.dart';
import 'package:mobile_2/core/utils/task_check.dart';

WorkTaskEntity _task({
  required TaskCheckingStrategy strategy,
  required String right,
  int highest = 5,
}) {
  return WorkTaskEntity(
    id: 't1',
    createdAt: DateTime.now(),
    workId: 'w1',
    type: WorkTaskType.word,
    content: RichText.empty(),
    highestScore: highest,
    order: 1,
    rightAnswer: right,
    checkingStrategy: strategy,
  );
}

void main() {
  group('TaskChecker Type1 (exact match ignoring spaces & case)', () {
    test('Russian letters: case-insensitive and spaces ignored', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type1,
        right: 'Москва',
        highest: 5,
      );
      expect(TaskChecker.checkAnswer('москва', task), 5);
      expect(TaskChecker.checkAnswer('МОСКВА', task), 5);
      expect(TaskChecker.checkAnswer('  москва  ', task), 5);
      // internal spaces should be ignored
      expect(TaskChecker.checkAnswer('мос ква', task), 5);
    });

    test('Non-matching letters returns 0', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type1,
        right: 'река',
        highest: 5,
      );
      expect(TaskChecker.checkAnswer('ре ки', task), 0);
      expect(TaskChecker.checkAnswer('ре кар', task), 0);
    });
  });

  group('TaskChecker Type2 (per-position penalty)', () {
    test('Exact match yields max score; spaces/case ignored', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type2,
        right: 'река',
        highest: 5,
      );
      expect(TaskChecker.checkAnswer('РЕКА', task), 5);
      expect(TaskChecker.checkAnswer('  р е к а  ', task), 5);
    });

    test('One letter different reduces by 1', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type2,
        right: 'река',
        highest: 5,
      );
      // internal space is ignored, should still be full score
      expect(TaskChecker.checkAnswer('ре ка', task), 5);
      // actual letter difference
      expect(TaskChecker.checkAnswer('реко', task), 4);
    });

    test('More differences never below zero', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type2,
        right: 'кот',
        highest: 2,
      );
      expect(TaskChecker.checkAnswer('собака', task), 0);
    });
  });

  group('TaskChecker Type3 (presence/extra penalty)', () {
    test('Same letters different order yields full score', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type3,
        right: 'кот',
        highest: 3,
      );
      expect(TaskChecker.checkAnswer('ТОК', task), 3);
      expect(TaskChecker.checkAnswer('к то', task), 3);
    });

    test('Extra letter penalizes by count (length diff == extras)', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type3,
        right: 'кот',
        highest: 3,
      );
      expect(TaskChecker.checkAnswer('коты', task), 2); // one extra letter
    });

    test('Mismatched extras return 0 (when diff != extras)', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type3,
        right: 'мир',
        highest: 3,
      );
      // Here extras include more letters counted than length diff, so invalid per JS logic
      expect(TaskChecker.checkAnswer('миаа', task), 0);
    });
  });

  group('TaskChecker Type4 (tolerant with small diffs)', () {
    test(
      'Exact match with spaces/case ignored yields max adjusted by length diff',
      () {
        final task = _task(
          strategy: TaskCheckingStrategy.type4,
          right: 'мир',
          highest: 5,
        );
        expect(TaskChecker.checkAnswer('МИР', task), 5);
        expect(TaskChecker.checkAnswer('  м и р  ', task), 5);
      },
    );

    test('One positional error: maxScore - 1', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type4,
        right: 'мир',
        highest: 5,
      );
      expect(TaskChecker.checkAnswer('мор', task), 4);
    });

    test('Length difference reduces maxScore by abs diff, <=2 errors cost -1', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type4,
        right: 'мир',
        highest: 5,
      );
      // extra letter "ы": length diff 1 -> base 4, no more than 2 errors -> 3 or 4 depending on mismatch count
      // Since we ignore spaces, compare letters only; extra letter also contributes to errorCount
      final score = TaskChecker.checkAnswer('миры', task);
      expect(score == 3 || score == 4, true);
    });

    test('Many errors yield 0', () {
      final task = _task(
        strategy: TaskCheckingStrategy.type4,
        right: 'дом',
        highest: 3,
      );
      expect(TaskChecker.checkAnswer('река', task), 0);
    });
  });
}
