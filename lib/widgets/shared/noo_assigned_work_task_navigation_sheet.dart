import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/widgets/shared/noo_subject.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_status_tags.dart';
import 'package:mobile_2/widgets/shared/noo_score_widget.dart';
import 'package:mobile_2/core/utils/date_helpers.dart';

class NooAssignedWorkTaskNavigationSheet extends StatefulWidget {
  final AssignedWorkEntity? assignedWork;
  final int currentTaskIndex;
  final Function(int) onTaskSelected;

  const NooAssignedWorkTaskNavigationSheet({
    super.key,
    required this.assignedWork,
    required this.currentTaskIndex,
    required this.onTaskSelected,
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

            return InkWell(
              onTap: () {
                widget.onTaskSelected(index);
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent
                        ? theme.colorScheme.secondary
                        : theme.dividerColor,
                    width: 2,
                  ),
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
