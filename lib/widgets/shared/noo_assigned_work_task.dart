import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/types/richtext.dart' as rt;
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_rich_text_display.dart';
import 'package:mobile_2/widgets/shared/noo_rich_text_editor.dart';
import 'package:mobile_2/widgets/shared/noo_task_criteria.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_input.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_word_counter.dart';

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

    final taskSolved =
        ((answer?.isSubmitted == true && comment?.score != null) ||
        mode == AssignedWorkMode.read);

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
                NooTextTitle('Задание $taskNumber'),
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
            mode == AssignedWorkMode.solve
                ? NooRichTextEditor(
                    initialRichText: answer?.content,
                    onChanged: (value) =>
                        onAnswerChanged?.call(task.id, null, value),
                  )
                : NooRichTextDisplay(
                    richText: answer?.content ?? rt.RichText.empty(),
                    padding: const EdgeInsets.all(0),
                  ),
          ],
          const SizedBox(height: 24),

          if (task.type == WorkTaskType.essay ||
              task.type == WorkTaskType.finalEssay) ...[
            NooWordCounter(
              richText: answer?.content ?? rt.RichText.empty(),
              maxCount: task.maxWordCount,
              minCount: task.minWordCount,
            ),
          ],

          // Right answer and score (if submitted and scored)
          if (taskSolved) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.rightAnswer != null &&
                    task.rightAnswer!.isNotEmpty) ...[
                  NooText('Правильный ответ:'),
                  const SizedBox(height: 8),
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
                    final score = comment?.score ?? 0;
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

          if (task.type == WorkTaskType.essay ||
              task.type == WorkTaskType.finalEssay ||
              task.type == WorkTaskType.dictation) ...[
            NooTextTitle('Критерии оценивания:', size: NooTitleSize.small),
            const SizedBox(height: 8),
            NooTaskCriteria(
              taskType: task.type,
              detailedScore: comment?.detailedScore,
            ),
            const SizedBox(height: 16),
          ],

          // Comment content (if submitted and scored)
          if (taskSolved &&
              comment?.content != null &&
              !comment!.content!.isEmpty()) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Комментарий куратора:'),
                const SizedBox(height: 8),
                NooRichTextDisplay(
                  richText: comment!.content!,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Solve hint
          if (task.solveHint != null && !task.solveHint!.isEmpty()) ...[
            NooCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NooTextTitle('Подсказка:'),
                  const SizedBox(height: 8),
                  NooRichTextDisplay(
                    richText: task.solveHint!,
                    padding: const EdgeInsets.all(0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Check hint (if submitted and scored)
          if (taskSolved &&
              task.checkHint != null &&
              !task.checkHint!.isEmpty()) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Пояснение:'),
                const SizedBox(height: 8),
                NooRichTextDisplay(
                  richText: task.checkHint!,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
          ],

          const SizedBox(height: 150),
        ],
      ),
    );
  }
}
