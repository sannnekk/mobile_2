import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/providers/assigned_work_providers.dart';
import 'package:mobile_2/widgets/shared/noo_assigned_work_task.dart';
import 'package:mobile_2/widgets/shared/noo_subject.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_status_tags.dart';
import 'package:mobile_2/widgets/shared/noo_score_widget.dart';
import 'package:mobile_2/core/utils/date_helpers.dart';

class NooAssignedWorkTaskNavigationSheet extends StatefulWidget {
  final AssignedWorkEntity? assignedWork;
  final AssignedWorkAnswersState answersState;
  final int currentTaskIndex;
  final Function(int) onTaskSelected;
  final ScrollController? scrollController;

  const NooAssignedWorkTaskNavigationSheet({
    super.key,
    required this.assignedWork,
    required this.answersState,
    required this.currentTaskIndex,
    required this.onTaskSelected,
    this.scrollController,
  });

  @override
  State<NooAssignedWorkTaskNavigationSheet> createState() =>
      _NooAssignedWorkTaskNavigationSheetState();
}

class _NooAssignedWorkTaskNavigationSheetState
    extends State<NooAssignedWorkTaskNavigationSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      return Colors.green; // success color
    }

    // Danger: (answer submitted, has comment, score == 0) OR (mode is read, work is checked, no comment)
    final isWorkChecked =
        work.checkStatus == AssignedWorkCheckStatus.checkedInDeadline ||
        work.checkStatus == AssignedWorkCheckStatus.checkedAfterDeadline ||
        work.checkStatus == AssignedWorkCheckStatus.checkedAutomatically;

    if ((hasAnswer && hasComment && commentScore == 0) ||
        (mode == AssignedWorkMode.read && isWorkChecked && !hasComment)) {
      return Colors.red; // danger color
    }

    // Warning: answer submitted, has comment, score != 0 and score != highestScore
    if (hasAnswer &&
        hasComment &&
        commentScore != 0 &&
        commentScore != task.highestScore.toDouble()) {
      return Colors.orange; // warning color
    }

    // Default: no special color
    return theme.dividerColor;
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
                  Tab(text: 'Информация о работе'),
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
            final borderColor = isCurrent
                ? theme.colorScheme.secondary
                : (widget.assignedWork != null
                      ? _getTaskBorderColor(
                          context,
                          widget.assignedWork!,
                          task,
                          answer,
                          comment,
                        )
                      : theme.dividerColor);

            return InkWell(
              onTap: () {
                widget.onTaskSelected(index);
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${task.order}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.titleMedium?.color ?? Colors.black,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
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
            NooText('Решена: ${formatDate(widget.assignedWork!.solvedAt!)}'),
          ],
          if (widget.assignedWork?.solveDeadlineAt != null) ...[
            NooText(
              'Дедлайн решения: ${formatDate(widget.assignedWork!.solveDeadlineAt!)}',
            ),
          ],
          if (widget.assignedWork?.checkedAt != null) ...[
            NooText(
              'Проверена: ${formatDate(widget.assignedWork!.checkedAt!)}',
            ),
          ],
          if (widget.assignedWork?.checkDeadlineAt != null) ...[
            NooText(
              'Дедлайн проверки: ${formatDate(widget.assignedWork!.checkDeadlineAt!)}',
            ),
          ],
          const SizedBox(height: 8),
          NooScoreWidget(
            score: widget.assignedWork?.score,
            maxScore: widget.assignedWork?.maxScore ?? 0,
          ),
        ],
      ),
    );
  }
}
