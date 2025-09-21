import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/types/richtext.dart' as rt;
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_rich_text_display.dart';
import 'package:mobile_2/widgets/shared/noo_rich_text_editor.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_input.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

enum AssignedWorkMode { read, solve, check }

class NooAssignedWorkTask extends StatelessWidget {
  final WorkTaskEntity task;
  final AssignedWorkAnswerEntity? answer;
  final AssignedWorkCommentEntity? comment;
  final AssignedWorkMode mode;
  final Function(String taskId, String? word, rt.RichText? content)?
  onAnswerChanged;
  final int taskNumber;

  const NooAssignedWorkTask({
    super.key,
    required this.task,
    this.answer,
    this.comment,
    required this.mode,
    this.onAnswerChanged,
    required this.taskNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task number
          NooCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Задание ${taskNumber}'),
                const SizedBox(height: 16),

                // Task content
                NooRichTextDisplay(
                  richText: task.content,
                  padding: const EdgeInsets.all(0),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input field
          if (mode == AssignedWorkMode.solve ||
              mode == AssignedWorkMode.read) ...[
            if (task.type == WorkTaskType.word) ...[
              NooTextInput(
                label: "Ваш ответ",
                initialValue: answer?.word,
                enabled: mode == AssignedWorkMode.solve,
                onChanged: mode == AssignedWorkMode.solve
                    ? (value) => onAnswerChanged?.call(task.id, value, null)
                    : null,
              ),
            ] else ...[
              NooRichTextEditor(
                initialRichText: answer?.content,
                readOnly: mode == AssignedWorkMode.read,
                onChanged: mode == AssignedWorkMode.solve
                    ? (value) => onAnswerChanged?.call(task.id, null, value)
                    : null,
              ),
            ],
            const SizedBox(height: 24),
          ],

          // Right answer and score (if submitted and scored)
          if (answer?.isSubmitted == true && comment?.score != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooText('Правильный ответ:'),
                const SizedBox(height: 8),
                if (task.rightAnswer != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (task.rightAnswer ?? '')
                        .split('|')
                        .map(
                          (answer) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: theme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: NooText(answer.trim()),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final score = comment!.score!;
                    final highestScore = task.highestScore;
                    final scoreText = '${score.toInt()}/$highestScore';

                    Color scoreColor;
                    if (score == highestScore.toDouble()) {
                      scoreColor = theme.colorScheme.primary; // success
                    } else if (score > 0) {
                      scoreColor = theme.colorScheme.tertiary; // warning
                    } else {
                      scoreColor = theme.colorScheme.error; // danger
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: scoreColor, width: 1),
                      ),
                      child: NooText('Балл: $scoreText'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Comment content (if submitted and scored)
          if (answer?.isSubmitted == true &&
              comment?.score != null &&
              comment?.content != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Комментарий куратора:'),
                const SizedBox(height: 8),
                NooRichTextDisplay(richText: comment!.content!),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Solve hint
          if (task.solveHint != null) ...[
            NooCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NooTextTitle('Подсказка:'),
                  const SizedBox(height: 8),
                  NooRichTextDisplay(richText: task.solveHint!),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Check hint (if submitted and scored)
          if (answer?.isSubmitted == true &&
              comment?.score != null &&
              task.checkHint != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Пояснение:'),
                const SizedBox(height: 8),
                NooRichTextDisplay(richText: task.checkHint!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
