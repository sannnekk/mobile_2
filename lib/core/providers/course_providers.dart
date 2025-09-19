import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/services/course_service.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';

part 'course_providers.g.dart';

@riverpod
Future<CourseService> courseService(CourseServiceRef ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return CourseService(client: client);
}

class CourseAssignmentsState {
  final List<CourseAssignmentEntity> assignments;
  final bool isLoading;
  final String? error;

  const CourseAssignmentsState({
    this.assignments = const [],
    this.isLoading = false,
    this.error,
  });

  CourseAssignmentsState copyWith({
    List<CourseAssignmentEntity>? assignments,
    bool? isLoading,
    String? error,
  }) {
    return CourseAssignmentsState(
      assignments: assignments ?? this.assignments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CourseAssignmentsNotifier extends StateNotifier<CourseAssignmentsState> {
  final CourseService _courseService;
  final String _studentId;
  final bool _isArchived;
  final Ref ref;

  CourseAssignmentsNotifier(
    this._courseService,
    this._studentId,
    this._isArchived,
    this.ref, {
    bool autoLoad = true,
  }) : super(const CourseAssignmentsState()) {
    // Load using the provided isArchived flag for the family instance
    if (autoLoad) {
      // Use microtask to avoid re-entrancy during provider mount
      Future.microtask(() => loadAssignments(isArchived: _isArchived));
    }
  }

  Future<void> loadAssignments({bool? isArchived}) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (_studentId.isEmpty) {
        if (!mounted) return;
        await this.ref.read(authStateProvider.notifier).logout();
        return;
      }
      final result =
          await ApiResponseHandler.handleCall<List<CourseAssignmentEntity>>(
            () async {
              return _courseService.getStudentCourseAssignments(
                _studentId,
                isArchived: isArchived ?? _isArchived,
              );
            },
          );
      if (!mounted) return;
      if (result.isSuccess && result.data != null) {
        state = state.copyWith(assignments: result.data!, isLoading: false);
      } else {
        state = state.copyWith(
          error: result.error ?? 'Неизвестная ошибка',
          isLoading: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refreshAssignments({bool? isArchived}) async {
    await loadAssignments(isArchived: isArchived);
  }
}

class CourseDetailState {
  final CourseEntity? course;
  final bool isLoading;
  final String? error;
  final String? selectedMaterialId;

  const CourseDetailState({
    this.course,
    this.isLoading = false,
    this.error,
    this.selectedMaterialId,
  });

  CourseDetailState copyWith({
    CourseEntity? course,
    bool? isLoading,
    String? error,
    String? selectedMaterialId,
  }) {
    return CourseDetailState(
      course: course ?? this.course,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedMaterialId: selectedMaterialId ?? this.selectedMaterialId,
    );
  }
}

class CourseDetailNotifier extends StateNotifier<CourseDetailState> {
  final CourseService _courseService;
  final String _courseSlug;
  final Ref ref;

  CourseDetailNotifier(
    this._courseService,
    this._courseSlug,
    this.ref, {
    bool autoLoad = true,
  }) : super(const CourseDetailState()) {
    if (autoLoad) {
      Future.microtask(() => load());
    }
  }

  Future<void> load() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ApiResponseHandler.handleCall<CourseEntity>(
        () async => _courseService.getCourseBySlug(_courseSlug),
      );
      if (!mounted) return;
      if (result.isSuccess && result.data != null) {
        state = state.copyWith(course: result.data!, isLoading: false);
        // Auto-select first material if available
        final firstMaterial = _findFirstMaterial(result.data!);
        if (firstMaterial != null) {
          selectMaterial(firstMaterial.id);
        }
      } else {
        state = state.copyWith(
          error: result.error ?? 'Неизвестная ошибка',
          isLoading: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void selectMaterial(String materialId) {
    state = state.copyWith(selectedMaterialId: materialId);
  }

  CourseMaterialEntity? _findFirstMaterial(CourseEntity course) {
    for (final chapter in course.chapters ?? []) {
      if (chapter.materials.isNotEmpty) {
        return chapter.materials.first;
      }
      // Recursively check sub-chapters
      final found = _findFirstMaterialInChapter(chapter);
      if (found != null) return found;
    }
    return null;
  }

  CourseMaterialEntity? _findFirstMaterialInChapter(
    CourseChapterEntity chapter,
  ) {
    for (final subChapter in chapter.chapters) {
      if (subChapter.materials.isNotEmpty) {
        return subChapter.materials.first;
      }
      final found = _findFirstMaterialInChapter(subChapter);
      if (found != null) return found;
    }
    return null;
  }

  Future<void> toggleReaction(String materialId, String reaction) async {
    if (!mounted || state.course == null) return;

    // Optimistically update the UI
    final updatedCourse = _updateMaterialReaction(
      state.course!,
      materialId,
      reaction,
    );
    state = state.copyWith(course: updatedCourse);

    try {
      final result = await ApiResponseHandler.handleCall<void>(
        () async => _courseService.toggleReaction(materialId, reaction),
      );
      if (!result.isSuccess) {
        // Revert on failure
        final revertedCourse = _updateMaterialReaction(
          state.course!,
          materialId,
          null,
        );
        state = state.copyWith(course: revertedCourse);
      }
    } catch (e) {
      // Revert on error
      final revertedCourse = _updateMaterialReaction(
        state.course!,
        materialId,
        null,
      );
      state = state.copyWith(course: revertedCourse);
    }
  }

  CourseEntity _updateMaterialReaction(
    CourseEntity course,
    String materialId,
    String? newReaction,
  ) {
    return CourseEntity(
      id: course.id,
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
      slug: course.slug,
      name: course.name,
      description: course.description,
      images: course.images,
      authors: course.authors,
      editors: course.editors,
      chapters: course.chapters
          ?.map(
            (chapter) =>
                _updateChapterReaction(chapter, materialId, newReaction),
          )
          .toList(),
      subject: course.subject,
      subjectId: course.subjectId,
      studentCount: course.studentCount,
    );
  }

  CourseChapterEntity _updateChapterReaction(
    CourseChapterEntity chapter,
    String materialId,
    String? newReaction,
  ) {
    return CourseChapterEntity(
      id: chapter.id,
      createdAt: chapter.createdAt,
      updatedAt: chapter.updatedAt,
      name: chapter.name,
      titleColor: chapter.titleColor,
      chapters: chapter.chapters
          .map(
            (subChapter) =>
                _updateChapterReaction(subChapter, materialId, newReaction),
          )
          .toList(),
      materials: chapter.materials.map((material) {
        if (material.id == materialId) {
          return CourseMaterialEntity(
            id: material.id,
            createdAt: material.createdAt,
            updatedAt: material.updatedAt,
            name: material.name,
            description: material.description,
            content: material.content,
            order: material.order,
            workId: material.workId,
            isActive: material.isActive,
            activateAt: material.activateAt,
            work: material.work,
            workSolveDeadline: material.workSolveDeadline,
            workCheckDeadline: material.workCheckDeadline,
            poll: material.poll,
            pollId: material.pollId,
            videos: material.videos,
            isWorkAvailable: material.isWorkAvailable,
            isPinned: material.isPinned,
            titleColor: material.titleColor,
            files: material.files,
            myReaction: newReaction,
          );
        }
        return material;
      }).toList(),
      order: chapter.order,
      isActive: chapter.isActive,
      isPinned: chapter.isPinned,
    );
  }
}

final courseAssignmentsNotifierProvider =
    StateNotifierProvider.family<
      CourseAssignmentsNotifier,
      CourseAssignmentsState,
      bool
    >((ref, isArchived) {
      final courseServiceAsync = ref.watch(courseServiceProvider);
      final authState = ref.watch(authStateProvider);

      return courseServiceAsync.maybeWhen(
        data: (courseService) {
          final payloadId = authState.userPayload?.userId;
          final userId = authState.user?.id;
          final studentId = payloadId ?? userId ?? '';
          return CourseAssignmentsNotifier(
            courseService,
            studentId,
            isArchived,
            ref,
            autoLoad: true,
          );
        },
        orElse: () => CourseAssignmentsNotifier(
          CourseService(),
          '',
          isArchived,
          ref,
          autoLoad: false,
        ),
      );
    });

final courseDetailProvider =
    StateNotifierProvider.family<
      CourseDetailNotifier,
      CourseDetailState,
      String
    >((ref, courseSlug) {
      final courseServiceAsync = ref.watch(courseServiceProvider);

      return courseServiceAsync.maybeWhen(
        data: (courseService) => CourseDetailNotifier(
          courseService,
          courseSlug,
          ref,
          autoLoad: true,
        ),
        orElse: () => CourseDetailNotifier(
          CourseService(),
          courseSlug,
          ref,
          autoLoad: false,
        ),
      );
    });
