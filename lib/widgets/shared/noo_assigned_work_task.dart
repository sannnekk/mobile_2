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

class NooAssignedWorkTask extends StatefulWidget {
  final WorkTaskEntity task;
  final AssignedWorkAnswerEntity? answer;
  final AssignedWorkCommentEntity? comment;
  final AssignedWorkMode mode;
  final Function(String taskId, String? word, rt.RichText?)? onAnswerChanged;
  final int taskNumber;
  final int focusRequestId;
  final bool shouldFocus;

  const NooAssignedWorkTask({
    super.key,
    required this.task,
    this.answer,
    this.comment,
    required this.mode,
    this.onAnswerChanged,
    required this.taskNumber,
    this.focusRequestId = 0,
    this.shouldFocus = false,
  });

  @override
  State<NooAssignedWorkTask> createState() => _NooAssignedWorkTaskState();
}

class _NooAssignedWorkTaskState extends State<NooAssignedWorkTask> {
  bool _showRightAnswer = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _richTextScrollController = ScrollController();
  final FocusNode _answerFocusNode = FocusNode();
  final GlobalKey _answerSectionKey = GlobalKey();
  bool _focusListenerAttached = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final taskSolved =
        ((widget.answer?.isSubmitted == true &&
            widget.comment?.score != null) ||
        widget.mode == AssignedWorkMode.read);

    final hasRightAnswer =
        widget.task.rightAnswer != null &&
        widget.task.rightAnswer!.trim().isNotEmpty;

    final canRevealBeforeCheck =
        widget.mode == AssignedWorkMode.solve &&
        widget.task.isAnswerVisibleBeforeCheck &&
        hasRightAnswer;

    if (!_focusListenerAttached) {
      _answerFocusNode.addListener(_handleFocusChange);
      _focusListenerAttached = true;
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task number
          NooCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Задание ${widget.taskNumber}'),
                const SizedBox(height: 16),

                // Task content
                NooRichTextDisplay(
                  richText: widget.task.content,
                  padding: const EdgeInsets.all(0),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input field
          if (widget.task.type == WorkTaskType.word) ...[
            Container(
              key: _answerSectionKey,
              child: NooTextInput(
                label: "Ваш ответ",
                initialValue: widget.answer?.word,
                enabled: widget.mode == AssignedWorkMode.solve,
                focusNode: _answerFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus) _scrollToAnswer();
                },
                onChanged: widget.mode == AssignedWorkMode.solve
                    ? (value) => widget.onAnswerChanged?.call(
                        widget.task.id,
                        value,
                        null,
                      )
                    : null,
              ),
            ),
          ] else ...[
            Container(
              key: _answerSectionKey,
              child: widget.mode == AssignedWorkMode.solve
                  ? NooRichTextEditor(
                      initialRichText: widget.answer?.content,
                      onChanged: (value) => widget.onAnswerChanged?.call(
                        widget.task.id,
                        null,
                        value,
                      ),
                      focusNode: _answerFocusNode,
                      onFocusChange: (hasFocus) {
                        if (hasFocus) _scrollToAnswer();
                      },
                      scrollController: _richTextScrollController,
                    )
                  : NooRichTextDisplay(
                      richText: widget.answer?.content ?? rt.RichText.empty(),
                      padding: const EdgeInsets.all(0),
                    ),
            ),
          ],
          const SizedBox(height: 24),

          // Toggle to reveal answer in solve mode (if allowed)
          if (canRevealBeforeCheck) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: Icon(
                  _showRightAnswer ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
                label: NooText(
                  _showRightAnswer ? 'Скрыть ответ' : 'Показать ответ',
                ),
                onPressed: () {
                  setState(() {
                    _showRightAnswer = !_showRightAnswer;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (widget.task.type == WorkTaskType.essay ||
              widget.task.type == WorkTaskType.finalEssay) ...[
            NooWordCounter(
              richText: widget.answer?.content ?? rt.RichText.empty(),
              maxCount: widget.task.maxWordCount,
              minCount: widget.task.minWordCount,
            ),
          ],

          // Right answer display (if solved OR revealed in solve mode)
          if (hasRightAnswer && (taskSolved || _showRightAnswer)) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooText('Правильный ответ:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (widget.task.rightAnswer ?? '')
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
            ),
            const SizedBox(height: 16),
          ],

          // Score (only if submitted and scored OR in read mode)
          if (taskSolved) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    final score = widget.comment?.score ?? 0;
                    final highestScore = widget.task.highestScore;
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

          if (widget.task.type == WorkTaskType.essay ||
              widget.task.type == WorkTaskType.finalEssay ||
              widget.task.type == WorkTaskType.dictation) ...[
            NooTextTitle('Критерии оценивания:', size: NooTitleSize.small),
            const SizedBox(height: 8),
            NooTaskCriteria(
              taskType: widget.task.type,
              detailedScore: widget.comment?.detailedScore,
            ),
            const SizedBox(height: 16),
          ],

          // Comment content (if submitted and scored)
          if (taskSolved &&
              widget.comment?.content != null &&
              !widget.comment!.content!.isEmpty()) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Комментарий куратора:'),
                const SizedBox(height: 8),
                NooRichTextDisplay(
                  richText: widget.comment!.content!,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Solve hint
          if (widget.task.solveHint != null &&
              !widget.task.solveHint!.isEmpty()) ...[
            NooCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NooTextTitle('Подсказка:'),
                  const SizedBox(height: 8),
                  NooRichTextDisplay(
                    richText: widget.task.solveHint!,
                    padding: const EdgeInsets.all(0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Check hint (if submitted and scored)
          if (taskSolved &&
              widget.task.checkHint != null &&
              !widget.task.checkHint!.isEmpty()) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Пояснение:'),
                const SizedBox(height: 8),
                NooRichTextDisplay(
                  richText: widget.task.checkHint!,
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

  @override
  void didUpdateWidget(NooAssignedWorkTask oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.mode != AssignedWorkMode.solve &&
        oldWidget.mode == AssignedWorkMode.solve &&
        _answerFocusNode.hasFocus) {
      _answerFocusNode.unfocus();
    }

    final shouldHandleFocus =
        widget.shouldFocus &&
        widget.focusRequestId != oldWidget.focusRequestId &&
        widget.focusRequestId != 0 &&
        widget.mode == AssignedWorkMode.solve;

    if (shouldHandleFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _requestAnswerFocus();
      });
    }
  }

  @override
  void dispose() {
    if (_focusListenerAttached) {
      _answerFocusNode.removeListener(_handleFocusChange);
    }
    _scrollController.dispose();
    _richTextScrollController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_answerFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToAnswer();
      });
    }
  }

  Future<void> _scrollToAnswer() async {
    final context = _answerSectionKey.currentContext;
    if (context == null) return;

    final shouldScrollToBottom = widget.task.type == WorkTaskType.word;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 250),
      alignment: shouldScrollToBottom ? 1.0 : 0.1,
      curve: Curves.easeInOut,
    );

    if (!shouldScrollToBottom || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    await _scrollController.animateTo(
      position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _requestAnswerFocus() {
    if (!_answerFocusNode.hasFocus) {
      _answerFocusNode.requestFocus();
    }
    _scrollToAnswer();
  }
}
