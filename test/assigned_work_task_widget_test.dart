import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mobile_2/widgets/shared/noo_assigned_work_task.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/types/richtext.dart' as rt;

void main() {
  group('NooAssignedWorkTask', () {
    WorkTaskEntity makeTask({
      bool isAnswerVisibleBeforeCheck = false,
      String? rightAnswer = 'foo|bar',
      WorkTaskType type = WorkTaskType.word,
    }) {
      return WorkTaskEntity(
        id: 't1',
        createdAt: DateTime.now(),
        workId: 'w1',
        type: type,
        content: rt.RichText.empty(),
        highestScore: 1,
        order: 1,
        rightAnswer: rightAnswer,
        isAnswerVisibleBeforeCheck: isAnswerVisibleBeforeCheck,
      );
    }

    testWidgets('shows toggle in solve mode when allowed', (tester) async {
      final task = makeTask(isAnswerVisibleBeforeCheck: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NooAssignedWorkTask(
              task: task,
              answer: null,
              comment: null,
              mode: AssignedWorkMode.solve,
              taskNumber: 1,
            ),
          ),
        ),
      );

      final toggleFinder = find.text('Показать ответ');
      expect(toggleFinder, findsOneWidget);

      await tester.ensureVisible(toggleFinder);
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(find.text('Правильный ответ:'), findsOneWidget);
    });

    testWidgets('no toggle when not allowed', (tester) async {
      final task = makeTask(isAnswerVisibleBeforeCheck: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NooAssignedWorkTask(
              task: task,
              answer: null,
              comment: null,
              mode: AssignedWorkMode.solve,
              taskNumber: 1,
            ),
          ),
        ),
      );

      expect(find.text('Показать ответ'), findsNothing);
    });
  });
}
