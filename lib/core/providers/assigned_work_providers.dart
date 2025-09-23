import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/services/assigned_work_service.dart';
import 'package:mobile_2/core/types/richtext.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'package:mobile_2/core/utils/debouncer.dart';

part 'assigned_work_providers.g.dart';

@riverpod
Future<AssignedWorkService> assignedWorkService(Ref ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return AssignedWorkService(client: client);
}

enum AssignedWorkTab { all, unsolved, unchecked, checked, archived }

class AssignedWorksState {
  final List<AssignedWorkEntity> works;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int? totalItems;
  final int itemsPerPage;
  final bool hasMorePages;

  const AssignedWorksState({
    this.works = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalItems,
    this.itemsPerPage = 20,
    this.hasMorePages = false,
  });

  int? get totalPages =>
      totalItems != null ? (totalItems! / itemsPerPage).ceil() : null;

  bool get hasNextPage =>
      hasMorePages || (totalPages != null && currentPage < totalPages!);

  bool get hasPreviousPage => currentPage > 1;

  AssignedWorksState copyWith({
    List<AssignedWorkEntity>? works,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalItems,
    int? itemsPerPage,
    bool? hasMorePages,
  }) {
    return AssignedWorksState(
      works: works ?? this.works,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

class AssignedWorksNotifier extends StateNotifier<AssignedWorksState> {
  final AssignedWorkService _service;
  final String _studentId;
  final AssignedWorkTab _tab;
  final Ref ref;

  AssignedWorksNotifier(
    this._service,
    this._studentId,
    this._tab,
    this.ref, {
    bool autoLoad = true,
  }) : super(const AssignedWorksState()) {
    if (autoLoad) {
      Future.microtask(() => loadWorks());
    }
  }

  Future<void> loadWorks({int? page}) async {
    if (!mounted) return;
    final targetPage = page ?? 1;
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (_studentId.isEmpty) {
        if (!mounted) return;
        state = state.copyWith(
          error: 'User not authenticated',
          isLoading: false,
        );
        return;
      }

      final (isArchived, solveStatuses, checkStatuses) = _getFiltersForTab(
        _tab,
      );

      final response = await _service.getStudentAssignedWorks(
        _studentId,
        isArchivedByStudent: isArchived,
        solveStatuses: solveStatuses,
        checkStatuses: checkStatuses,
        page: targetPage,
        limit: state.itemsPerPage,
      );

      if (!mounted) return;

      if (response is ApiListResponse<AssignedWorkEntity>) {
        state = state.copyWith(
          works: response.data,
          isLoading: false,
          currentPage: targetPage,
          totalItems: response.total,
          hasMorePages: response.data.length == state.itemsPerPage,
        );
      } else if (response is ApiErrorResponse) {
        state = state.copyWith(error: response.error, isLoading: false);
      } else {
        state = state.copyWith(error: 'Неизвестная ошибка', isLoading: false);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refreshWorks() async {
    await loadWorks(page: 1);
  }

  Future<void> loadNextPage() async {
    if (state.hasNextPage) {
      await loadWorks(page: state.currentPage + 1);
    }
  }

  Future<void> loadPreviousPage() async {
    if (state.hasPreviousPage) {
      await loadWorks(page: state.currentPage - 1);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && (state.totalPages == null || page <= state.totalPages!)) {
      await loadWorks(page: page);
    }
  }

  Future<void> archiveWork(String workId) async {
    try {
      final result = await ApiResponseHandler.handleCall<void>(
        () async => _service.archiveAssignedWork(workId),
      );
      if (result.isSuccess) {
        // Remove the work from the list
        state = state.copyWith(
          works: state.works.where((work) => work.id != workId).toList(),
        );
      }
    } catch (e) {
      // Handle error - could show snackbar
    }
  }

  Future<void> deleteWork(String workId) async {
    try {
      final result = await ApiResponseHandler.handleCall<void>(
        () async => _service.deleteAssignedWork(workId),
      );
      if (result.isSuccess) {
        // Remove the work from the list
        state = state.copyWith(
          works: state.works.where((work) => work.id != workId).toList(),
        );
      }
    } catch (e) {
      // Handle error - could show snackbar
    }
  }

  (bool?, List<String>?, List<String>?) _getFiltersForTab(AssignedWorkTab tab) {
    switch (tab) {
      case AssignedWorkTab.all:
        return (false, null, null);
      case AssignedWorkTab.unsolved:
        return (false, ['not-started', 'in-progress'], null);
      case AssignedWorkTab.unchecked:
        return (
          false,
          ['made-in-deadline', 'made-after-deadline'],
          ['not-checked', 'in-progress'],
        );
      case AssignedWorkTab.checked:
        return (
          false,
          null,
          [
            'checked-in-deadline',
            'checked-after-deadline',
            'checked-automatically',
          ],
        );
      case AssignedWorkTab.archived:
        return (true, null, null);
    }
  }
}

final assignedWorksNotifierProvider =
    StateNotifierProvider.family<
      AssignedWorksNotifier,
      AssignedWorksState,
      AssignedWorkTab
    >((ref, tab) {
      final serviceAsync = ref.watch(assignedWorkServiceProvider);
      final authState = ref.watch(authStateProvider);

      return serviceAsync.maybeWhen(
        data: (service) {
          final payloadId = authState.userPayload?.userId;
          final userId = authState.user?.id;
          final studentId = payloadId ?? userId ?? '';
          return AssignedWorksNotifier(
            service,
            studentId,
            tab,
            ref,
            autoLoad: true,
          );
        },
        orElse: () => AssignedWorksNotifier(
          AssignedWorkService(),
          '',
          tab,
          ref,
          autoLoad: false,
        ),
      );
    });

@riverpod
Future<AssignedWorkEntity> assignedWorkDetail(Ref ref, String workId) async {
  final service = await ref.watch(assignedWorkServiceProvider.future);
  final response = await service.getAssignedWork(workId);
  final result = ApiResponseHandler.handle(response);
  if (result.isSuccess) {
    return result.data!;
  } else {
    throw Exception(result.error ?? 'Не удалось загрузить работу');
  }
}

class AssignedWorkAnswersState {
  final Map<String, AssignedWorkAnswerEntity> answers;
  final bool isSaving;
  final String? saveError;

  const AssignedWorkAnswersState({
    this.answers = const {},
    this.isSaving = false,
    this.saveError,
  });

  AssignedWorkAnswersState copyWith({
    Map<String, AssignedWorkAnswerEntity>? answers,
    bool? isSaving,
    String? saveError,
  }) {
    return AssignedWorkAnswersState(
      answers: answers ?? this.answers,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError ?? this.saveError,
    );
  }
}

class AssignedWorkAnswersNotifier
    extends StateNotifier<AssignedWorkAnswersState> {
  final AssignedWorkService _service;
  final String _assignedWorkId;
  final Ref _ref;
  final Debouncer _debouncer;

  AssignedWorkAnswersNotifier(this._service, this._assignedWorkId, this._ref)
    : _debouncer = Debouncer(delay: const Duration(milliseconds: 1000)),
      super(const AssignedWorkAnswersState()) {
    // Keep answers in sync with the latest work details while this notifier is alive.
    // Using listen avoids creating a hard dependency chain that could keep providers alive unnecessarily.
    _ref.listen<AsyncValue<AssignedWorkEntity>>(
      assignedWorkDetailProvider(_assignedWorkId),
      (previous, next) {
        next.whenData((work) {
          final answersMap = <String, AssignedWorkAnswerEntity>{};
          for (final answer in work.answers) {
            answersMap[answer.taskId] = answer;
          }
          state = state.copyWith(answers: answersMap);
        });
      },
      fireImmediately: true,
    );
  }

  void updateAnswer(String taskId, String? word, RichText? content) {
    final existingAnswer = state.answers[taskId];
    final updatedAnswer = existingAnswer != null
        ? AssignedWorkAnswerEntity(
            id: existingAnswer.id,
            createdAt: existingAnswer.createdAt,
            updatedAt: DateTime.now(),
            taskId: taskId,
            word: word,
            content: content,
            isSubmitted: existingAnswer.isSubmitted,
            score: existingAnswer.score,
          )
        : AssignedWorkAnswerEntity(
            id: '', // Will be set by server
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            taskId: taskId,
            word: word,
            content: content,
          );

    state = state.copyWith(answers: {...state.answers, taskId: updatedAnswer});

    // Debounce the save
    _debouncer.debounce(() => _saveAnswer(updatedAnswer));
  }

  Future<void> _saveAnswer(AssignedWorkAnswerEntity answer) async {
    if (!mounted) return;

    state = state.copyWith(isSaving: true, saveError: null);
    try {
      final response = await _service.saveAnswer(_assignedWorkId, answer);
      final result = ApiResponseHandler.handle(response);
      if (result.isSuccess && mounted) {
        final savedAnswerId = result.data!;
        final savedAnswer = AssignedWorkAnswerEntity(
          id: savedAnswerId,
          createdAt: answer.createdAt,
          updatedAt: answer.updatedAt,
          taskId: answer.taskId,
          word: answer.word,
          content: answer.content,
          isSubmitted: answer.isSubmitted,
          score: answer.score,
        );
        state = state.copyWith(
          answers: {...state.answers, answer.taskId: savedAnswer},
          isSaving: false,
        );
      } else if (mounted) {
        state = state.copyWith(
          isSaving: false,
          saveError: result.error ?? 'Ошибка сохранения',
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isSaving: false, saveError: e.toString());
      }
    }
  }

  void triggerSave() {
    _debouncer.debounce(() {});
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}

final assignedWorkAnswersProvider = StateNotifierProvider.autoDispose
    .family<AssignedWorkAnswersNotifier, AssignedWorkAnswersState, String>((
      ref,
      assignedWorkId,
    ) {
      final serviceAsync = ref.watch(assignedWorkServiceProvider);
      final service = serviceAsync.maybeWhen(
        data: (s) => s,
        orElse: () => AssignedWorkService(),
      );
      return AssignedWorkAnswersNotifier(service, assignedWorkId, ref);
    });
