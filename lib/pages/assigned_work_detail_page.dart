import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/providers/assigned_work_providers.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'package:mobile_2/styles/colors.dart';
import 'package:mobile_2/widgets/shared/noo_assigned_work_task.dart';
import 'package:mobile_2/widgets/shared/noo_assigned_work_task_navigation_sheet.dart';
import 'package:mobile_2/widgets/shared/noo_button.dart';
import 'package:mobile_2/widgets/shared/noo_error_view.dart';
import 'package:mobile_2/widgets/shared/noo_loading_overlay.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_work_submitted_modal.dart';
import 'package:mobile_2/widgets/shared/draggable_bottom_sheet.dart';
import 'package:mobile_2/core/types/richtext.dart' as rt;

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
  int _focusTargetIndex = 0;
  int _focusRequestId = 0;
  bool _hasInitializedPage = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _isSubmitting = false;
  rt.RichText? _studentCommentDraft;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sheetController.dispose();
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
    // Save current answer before switching
    final answersNotifier = ref.read(
      assignedWorkAnswersProvider(widget.workId).notifier,
    );
    answersNotifier.triggerSave();

    setState(() {
      _currentTaskIndex = index;
      _focusTargetIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    Future(
      () => _sheetController.animateTo(
        0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentTaskIndex = index;
      _focusTargetIndex = index;
      if (_hasInitializedPage) {
        _focusRequestId++;
      } else {
        _hasInitializedPage = true;
      }
    });
  }

  void _sendWork() async {
    final workAsync = ref.read(assignedWorkDetailProvider(widget.workId));
    final answersState = ref.read(assignedWorkAnswersProvider(widget.workId));

    workAsync.whenData((work) async {
      final tasks = work.work?.tasks ?? [];
      final unsolvedTaskOrders = _collectUnsolvedTaskOrders(
        tasks,
        answersState.answers,
      );

      final shouldSubmit = await _showSubmitConfirmationDialog(
        unsolvedTaskOrders: unsolvedTaskOrders,
      );

      if (shouldSubmit != true) {
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final answers = answersState.answers.values.toList();

        // Call the solve API
        final service = await ref.read(assignedWorkServiceProvider.future);
        final response = await service.solveAssignedWork(
          widget.workId,
          answers,
          studentComment: _studentCommentDraft ?? work.studentComment,
          mentorComment: work.mentorComment,
        );
        final result = ApiResponseHandler.handle(response);

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          if (result.isSuccess) {
            // Show success modal
            _showSuccessModal();
          } else {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.error ?? 'Ошибка отправки работы'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  List<int> _collectUnsolvedTaskOrders(
    List<WorkTaskEntity> tasks,
    Map<String, AssignedWorkAnswerEntity> answers,
  ) {
    return tasks
        .where((task) => _isTaskAnswerEmpty(task, answers[task.id]))
        .map((task) => task.order)
        .toList()
      ..sort();
  }

  bool _isTaskAnswerEmpty(
    WorkTaskEntity task,
    AssignedWorkAnswerEntity? answer,
  ) {
    if (answer == null) return true;

    switch (task.type) {
      case WorkTaskType.word:
        final value = answer.word?.trim() ?? '';
        return value.isEmpty;
      case WorkTaskType.text:
      case WorkTaskType.essay:
      case WorkTaskType.finalEssay:
      case WorkTaskType.dictation:
        final content = answer.content;
        return content == null || content.isEmpty();
    }
  }

  Future<bool?> _showSubmitConfirmationDialog({
    required List<int> unsolvedTaskOrders,
  }) async {
    if (!mounted) return false;

    final hasUnsolvedTasks = unsolvedTaskOrders.isNotEmpty;
    final unsolvedList = unsolvedTaskOrders.getRange(0, 10).join(', ');

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: const Text('Отправить работу?'),
          backgroundColor: theme.colorScheme.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Вы уверены, что хотите отправить работу на проверку?',
              ),
              if (hasUnsolvedTasks) ...[
                const SizedBox(height: 12),
                Text(
                  'Не во всех заданиях есть ответы. Проверьте задания: $unsolvedList',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            NooButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              label: 'Отмена',
              style: NooButtonStyle.tertiary,
            ),
            NooButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              label: 'Отправить',
            ),
          ],
        );
      },
    );
  }

  void _showSuccessModal() {
    final router = GoRouter.of(context);
    showDialog(
      context: context,
      barrierDismissible: false, // Make it uncloseable
      builder: (dialogContext) => NooWorkSubmittedModal(
        onViewWork: () async {
          Navigator.of(dialogContext).pop(); // Close modal
          await _refetchWork();
        },
        onReturnToList: () {
          Navigator.of(dialogContext).pop(); // Close modal
          if (router.canPop()) {
            router.pop();
          } else {
            router.go('/assigned_works');
          }
        },
      ),
    );
  }

  Future<void> _refetchWork() async {
    // Invalidate the provider to refetch the work
    ref.invalidate(assignedWorkDetailProvider(widget.workId));
    ref.invalidate(assignedWorkAnswersProvider(widget.workId));
    // Small delay to allow the providers to refetch
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workAsync = ref.watch(assignedWorkDetailProvider(widget.workId));
    final answersState = ref.watch(assignedWorkAnswersProvider(widget.workId));

    return NooLoadingOverlay(
      isLoading: _isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.secondary,
          title: NooTextTitle('Работа', size: NooTitleSize.small),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/assigned_works');
              }
            },
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
          data: (work) => _buildContent(work, answersState),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => NooErrorView(error: error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(
    AssignedWorkEntity work,
    AssignedWorkAnswersState answersState,
  ) {
    final tasks = work.work?.tasks ?? [];
    final mode = _getMode(work);
    _studentCommentDraft = _studentCommentDraft ?? work.studentComment;

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

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final answer = answersState.answers[task.id];
            final comment = work.comments
                .where((c) => c.taskId == task.id)
                .firstOrNull;

            return NooAssignedWorkTask(
              key: ValueKey(task.id),
              task: task,
              answer: answer,
              comment: comment,
              mode: mode,
              taskNumber: task.order,
              onAnswerChanged: (taskId, word, content) {
                final answersNotifier = ref.read(
                  assignedWorkAnswersProvider(widget.workId).notifier,
                );
                answersNotifier.updateAnswer(taskId, word, content);
              },
              focusRequestId: _focusRequestId,
              shouldFocus:
                  mode == AssignedWorkMode.solve &&
                  _focusRequestId > 0 &&
                  index == _focusTargetIndex,
            );
          },
        ),
        DraggableBottomSheet(
          controller: _sheetController,
          initialChildSize: 0.1,
          minChildSize: 0.1,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.1, 0.85],
          minimizedWidget: Text(
            '${_currentTaskIndex + 1} / ${work.work?.tasks?.length ?? 0}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          child: NooAssignedWorkTaskNavigationSheet(
            assignedWork: work,
            answersState: answersState,
            currentTaskIndex: _currentTaskIndex,
            onTaskSelected: _onTaskSelected,
            onWorkUpdated: () {
              ref.invalidate(assignedWorkDetailProvider(widget.workId));
            },
            studentCommentDraft: _studentCommentDraft,
            onStudentCommentChanged: (value) {
              setState(() {
                _studentCommentDraft = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
