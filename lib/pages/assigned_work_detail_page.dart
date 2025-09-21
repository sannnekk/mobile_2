import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/core/providers/assigned_work_providers.dart';
import 'package:mobile_2/widgets/shared/noo_assigned_work_task.dart';
import 'package:mobile_2/widgets/shared/noo_assigned_work_task_navigation_sheet.dart';
import 'package:mobile_2/widgets/shared/noo_error_view.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

class AssignedWorkDetailPage extends ConsumerStatefulWidget {
  final String workId;

  const AssignedWorkDetailPage({super.key, required this.workId});

  @override
  ConsumerState<AssignedWorkDetailPage> createState() =>
      _AssignedWorkDetailPageState();
}

class _AssignedWorkDetailPageState
    extends ConsumerState<AssignedWorkDetailPage> {
  late PageController _pageController;
  int _currentTaskIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  void _onTaskSelected(int index) {
    setState(() {
      _currentTaskIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentTaskIndex = index;
    });
  }

  void _showTaskNavigationSheet(AssignedWorkEntity work) {
    showModalBottomSheet(
      context: context,
      builder: (context) => NooAssignedWorkTaskNavigationSheet(
        assignedWork: work,
        currentTaskIndex: _currentTaskIndex,
        onTaskSelected: _onTaskSelected,
      ),
    );
  }

  void _sendWork() {
    // TODO: Implement sending the work
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отправка работы не реализована')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workAsync = ref.watch(assignedWorkDetailProvider(widget.workId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        title: NooTextTitle('Работа', size: NooTitleSize.small),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/assigned_works'),
        ),
        actions: workAsync.maybeWhen(
          data: (work) {
            final mode = _getMode(work);
            if (mode == AssignedWorkMode.solve) {
              return [
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendWork,
                  tooltip: 'Отправить работу',
                ),
              ];
            }
            return null;
          },
          orElse: () => null,
        ),
      ),
      body: workAsync.when(
        data: (work) => _buildContent(work),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => NooErrorView(error: error.toString()),
      ),
      bottomNavigationBar: workAsync.maybeWhen(
        data: (work) => BottomAppBar(
          color: theme.colorScheme.surface,
          elevation: 14,
          shadowColor: theme.colorScheme.onSurface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () => _showTaskNavigationSheet(work),
                tooltip: 'Навигация по заданиям',
              ),
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Detect upward swipe
                  if (details.delta.dy < -10) {
                    // Negative delta means upward movement
                    _showTaskNavigationSheet(work);
                  }
                },
                child: Text(
                  '${_currentTaskIndex + 1} / ${work.work?.tasks?.length ?? 0}',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: 48), // Balance the icon button
            ],
          ),
        ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildContent(AssignedWorkEntity work) {
    final tasks = work.work?.tasks ?? [];
    final mode = _getMode(work);

    if (mode == AssignedWorkMode.check) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Режим проверки пока не поддерживается в этой версии приложения.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (tasks.isEmpty) {
      return const Center(child: Text('Задания не найдены'));
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final answer = work.answers
            .where((a) => a.taskId == task.id)
            .firstOrNull;
        final comment = work.comments
            .where((c) => c.taskId == task.id)
            .firstOrNull;

        return NooAssignedWorkTask(
          task: task,
          answer: answer,
          comment: comment,
          mode: mode,
          taskNumber: task.order,
          onAnswerChanged: (taskId, word, content) {
            // TODO: Handle answer changes
          },
        );
      },
    );
  }
}
