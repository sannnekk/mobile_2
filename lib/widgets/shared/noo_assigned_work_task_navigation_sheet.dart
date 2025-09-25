import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/providers/assigned_work_providers.dart';
import 'package:mobile_2/core/services/assigned_work_service.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'package:mobile_2/styles/colors.dart';
import 'package:mobile_2/widgets/shared/noo_assigned_work_task.dart';
import 'package:mobile_2/widgets/shared/noo_button.dart';
import 'package:mobile_2/widgets/shared/noo_loader.dart';
import 'package:mobile_2/widgets/shared/noo_subject.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_rich_text_display.dart';
import 'package:mobile_2/widgets/shared/noo_rich_text_editor.dart';
import 'package:mobile_2/core/types/richtext.dart' as rt;
import 'package:mobile_2/widgets/shared/noo_status_tags.dart';
import 'package:mobile_2/widgets/shared/noo_score_widget.dart';
import 'package:mobile_2/widgets/shared/noo_user_info_card.dart';
import 'package:mobile_2/core/utils/date_helpers.dart';

class NooAssignedWorkTaskNavigationSheet extends StatefulWidget {
  final AssignedWorkEntity? assignedWork;
  final AssignedWorkAnswersState answersState;
  final int currentTaskIndex;
  final Function(int) onTaskSelected;
  final ScrollController? scrollController;
  final VoidCallback? onWorkUpdated;
  // Draft of student comment lifted to parent (detail page)
  final rt.RichText? studentCommentDraft;
  final ValueChanged<rt.RichText>? onStudentCommentChanged;

  const NooAssignedWorkTaskNavigationSheet({
    super.key,
    required this.assignedWork,
    required this.answersState,
    required this.currentTaskIndex,
    required this.onTaskSelected,
    this.scrollController,
    this.onWorkUpdated,
    this.studentCommentDraft,
    this.onStudentCommentChanged,
  });

  @override
  State<NooAssignedWorkTaskNavigationSheet> createState() =>
      _NooAssignedWorkTaskNavigationSheetState();
}

class _NooAssignedWorkTaskNavigationSheetState
    extends State<NooAssignedWorkTaskNavigationSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isShiftingDeadline = false;
  bool _isRemakingWork = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AssignedWorkMode _getMode(AssignedWorkEntity work) {
    // Check if it's in check mode (checked statuses)
    if (work.checkStatus == AssignedWorkCheckStatus.checkedInDeadline ||
        work.checkStatus == AssignedWorkCheckStatus.checkedAfterDeadline ||
        work.checkStatus == AssignedWorkCheckStatus.checkedAutomatically) {
      return AssignedWorkMode.read;
    }

    // Otherwise, based on solve status
    switch (work.solveStatus) {
      case AssignedWorkSolveStatus.notStarted:
      case AssignedWorkSolveStatus.inProgress:
        return AssignedWorkMode.solve;
      case AssignedWorkSolveStatus.madeInDeadline:
      case AssignedWorkSolveStatus.madeAfterDeadline:
        return AssignedWorkMode.read;
    }
  }

  Color _getTaskBorderColor(
    BuildContext context,
    AssignedWorkEntity work,
    WorkTaskEntity task,
    AssignedWorkAnswerEntity? answer,
    AssignedWorkCommentEntity? comment,
  ) {
    final theme = Theme.of(context);
    final mode = _getMode(work);
    final hasAnswer = answer != null;
    final hasComment = comment != null;
    final commentScore = comment?.score;

    // Success: answer submitted, has comment, and comment.score == task.highestScore
    if (hasAnswer &&
        hasComment &&
        commentScore == task.highestScore.toDouble()) {
      return AppColors.success; // success color
    }

    // Danger: (answer submitted, has comment, score == 0) OR (mode is read, work is checked, no comment)
    final isWorkChecked =
        work.checkStatus == AssignedWorkCheckStatus.checkedInDeadline ||
        work.checkStatus == AssignedWorkCheckStatus.checkedAfterDeadline ||
        work.checkStatus == AssignedWorkCheckStatus.checkedAutomatically;

    if ((hasAnswer && hasComment && commentScore == 0) ||
        (mode == AssignedWorkMode.read && isWorkChecked && !hasComment)) {
      return AppColors.danger; // danger color
    }

    // Warning: answer submitted, has comment, score != 0 and score != highestScore
    if (hasAnswer &&
        hasComment &&
        commentScore != 0 &&
        commentScore != task.highestScore.toDouble()) {
      return AppColors.warning; // warning color
    }

    // Default: no special color
    return theme.dividerColor;
  }

  Future<void> _showShiftDeadlineDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сдвинуть дедлайн'),
        content: const Text(
          'Вы действительно хотите сдвинуть дедлайн на 3 дня?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Сдвинуть'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _shiftDeadline(context);
    }
  }

  Future<void> _showRemakeWorkDialog(BuildContext context) async {
    bool onlyFalse = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Переделать работу'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Вы действительно хотите переделывать работу?'),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text(
                  'Переделать только неправильно решенные задания',
                ),
                value: onlyFalse,
                onChanged: (value) {
                  setState(() {
                    onlyFalse = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Переделать'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _remakeWork(context, onlyFalse);
    }
  }

  Future<void> _shiftDeadline(BuildContext context) async {
    if (widget.assignedWork == null) return;

    setState(() {
      _isShiftingDeadline = true;
    });

    try {
      final service = AssignedWorkService();
      final response = await service.shiftDeadline(widget.assignedWork!.id);

      if (ApiResponseHandler.handle(response).isSuccess) {
        // Update local deadline - parent component should refresh the data
        widget.onWorkUpdated?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Дедлайн успешно сдвинут')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось сдвинуть дедлайн')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Произошла ошибка при сдвиге дедлайна')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isShiftingDeadline = false;
        });
      }
    }
  }

  Future<void> _remakeWork(BuildContext context, bool onlyFalse) async {
    if (widget.assignedWork == null) return;

    setState(() {
      _isRemakingWork = true;
    });

    try {
      final service = AssignedWorkService();
      final response = await service.remakeAssignedWork(
        widget.assignedWork!.id,
        onlyFalse: onlyFalse,
      );

      if (ApiResponseHandler.handle(response).isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Новая работа появилась в списке')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось переделать работу')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Произошла ошибка, не удалось переделать работу'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRemakingWork = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NooTabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Задания'),
                  Tab(text: 'Работа'),
                  Tab(text: 'Комментарии'),
                ],
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksTab(context, theme),
                _buildInfoTab(context, theme),
                _buildCommentsTab(context, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = screenWidth < 600 ? 8 : 10;
        final tasks = widget.assignedWork?.work?.tasks ?? [];
        final mode = widget.assignedWork == null
            ? null
            : _getMode(widget.assignedWork!);

        return GridView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final isCurrent = index == widget.currentTaskIndex;
            final answer = widget.answersState.answers[task.id];
            final comment = widget.assignedWork?.comments
                .where((c) => c.taskId == task.id)
                .firstOrNull;
            final hasAnswer = answer != null;
            final borderColor = (widget.assignedWork != null
                ? _getTaskBorderColor(
                    context,
                    widget.assignedWork!,
                    task,
                    answer,
                    comment,
                  )
                : theme.dividerColor);
            final backgroundColor = isCurrent ? theme.dividerColor : null;

            return InkWell(
              onTap: () {
                widget.onTaskSelected(index);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 2),
                  color: backgroundColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${task.order}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.textTheme.titleMedium?.color ??
                              Colors.black,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      if (hasAnswer && mode == AssignedWorkMode.solve) ...[
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoTab(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NooSubject(subject: widget.assignedWork?.work?.subject),
          const SizedBox(height: 8),
          NooTextTitle(widget.assignedWork?.work?.name ?? '-'),
          const SizedBox(height: 8),
          NooStatusTags(
            solveStatus:
                widget.assignedWork?.solveStatus ??
                AssignedWorkSolveStatus.notStarted,
            checkStatus:
                widget.assignedWork?.checkStatus ??
                AssignedWorkCheckStatus.notChecked,
          ),
          const SizedBox(height: 8),
          if (widget.assignedWork?.solvedAt != null) ...[
            NooText(
              'Решена: ${formatDate(widget.assignedWork!.solvedAt!)}',
              dimmed: true,
            ),
          ],
          if (widget.assignedWork?.solveDeadlineAt != null) ...[
            NooText(
              'Дедлайн решения: ${formatDate(widget.assignedWork!.solveDeadlineAt!)}',
              dimmed: true,
            ),
          ],
          if (widget.assignedWork?.checkedAt != null) ...[
            NooText(
              'Проверена: ${formatDate(widget.assignedWork!.checkedAt!)}',
              dimmed: true,
            ),
          ],
          if (widget.assignedWork?.checkDeadlineAt != null) ...[
            NooText(
              'Дедлайн проверки: ${formatDate(widget.assignedWork!.checkDeadlineAt!)}',
              dimmed: true,
            ),
          ],
          const SizedBox(height: 8),
          NooScoreWidget(
            score: widget.assignedWork?.score,
            maxScore: widget.assignedWork?.maxScore ?? 0,
          ),
          if (widget.assignedWork?.mentors != null &&
              widget.assignedWork!.mentors!.isNotEmpty) ...[
            const SizedBox(height: 16),
            NooText('Проверяющие кураторы'),
            const SizedBox(height: 8),
            ...widget.assignedWork!.mentors!.map(
              (mentor) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NooUserInfoCard(user: mentor, compact: true),
              ),
            ),
          ],
          if (widget.assignedWork?.isRemakeable) ...[
            _isRemakingWork
                ? const NooLoader()
                : NooButton(
                    label: 'Переделать работу',
                    onPressed: () {
                      _showRemakeWorkDialog(context);
                    },
                    style: NooButtonStyle.secondary,
                  ),
          ],
          if (widget.assignedWork?.deadlineShifteable) ...[
            _isShiftingDeadline
                ? const NooLoader()
                : NooButton(
                    label: 'Сдвинуть дедлайн',
                    onPressed: () {
                      _showShiftDeadlineDialog(context);
                    },
                    style: NooButtonStyle.secondary,
                  ),
          ],
          const SizedBox(height: 12),
          const NooText(
            'Сохранение работы происходит автоматически, если есть интернет-соединение.',
            dimmed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(BuildContext context, ThemeData theme) {
    final work = widget.assignedWork;
    if (work == null) {
      return const Center(child: NooText('Загрузка...'));
    }

    final mode = _getMode(work);
    final isReadOnly = mode != AssignedWorkMode.solve;
    final initialStudentComment =
        widget.studentCommentDraft ?? work.studentComment;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student comment (editable in solve mode)
          NooTextTitle('Передать привет куратору', size: NooTitleSize.small),
          const SizedBox(height: 8),
          if (isReadOnly)
            NooRichTextDisplay(
              richText: initialStudentComment ?? rt.RichText.empty(),
              padding: const EdgeInsets.all(0),
            )
          else
            NooRichTextEditor(
              initialRichText: initialStudentComment,
              onChanged: (value) => widget.onStudentCommentChanged?.call(value),
            ),

          const SizedBox(height: 24),

          // Mentor comment (always display only if present)
          if (work.mentorComment != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle('Комментарий куратора', size: NooTitleSize.small),
                const SizedBox(height: 8),
                NooRichTextDisplay(
                  richText: work.mentorComment!,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
