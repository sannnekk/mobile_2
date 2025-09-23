import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/core/providers/course_providers.dart';
import 'package:mobile_2/widgets/shared/noo_course_card.dart';
import 'package:mobile_2/widgets/shared/noo_cards_grid.dart';
import 'package:mobile_2/widgets/shared/noo_empty_list.dart';
import 'package:mobile_2/widgets/shared/noo_error_view.dart';
import 'package:mobile_2/widgets/shared/noo_pagination.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursesPage extends ConsumerStatefulWidget {
  const CoursesPage({super.key});

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<bool> _loaded;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loaded = [true, false];
    _tabController.addListener(_handleTabChange);
    // Load the first tab
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTab(0));
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _loadTab(_tabController.index);
    }
  }

  void _loadTab(int index) {
    if (!_loaded[index]) {
      final isArchived = index == 1;
      ref
          .read(courseAssignmentsNotifierProvider(isArchived).notifier)
          .loadAssignments();
      _loaded[index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NooTabBar(
          controller: _tabController,
          tabs: const [Text('Все'), Text('Архив')],
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildAllCoursesTab(), _buildArchivedCoursesTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildAllCoursesTab() {
    final courseState = ref.watch(courseAssignmentsNotifierProvider(false));
    final courseNotifier = ref.read(
      courseAssignmentsNotifierProvider(false).notifier,
    );

    if (courseState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courseState.error != null) {
      return NooErrorView(
        error: courseState.error!,
        onRetry: () => courseNotifier.refreshAssignments(isArchived: false),
      );
    }

    final courses = courseState.assignments;

    if (courses.isEmpty) {
      return NooEmptyList(
        title: 'Нет курсов',
        message: 'У вас пока нет доступных курсов',
        child: TextButton(
          onPressed: () async {
            final url = Uri.parse('https://no-os.ru');
            try {
              await launchUrl(url);
            } catch (e) {
              // Nothing to do
            }
          },
          child: const Text('Купить курсы на no-os.ru'),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                courseNotifier.refreshAssignments(isArchived: false),
            child: NooResponsiveCardsGrid<CourseAssignmentEntity>(
              items: courses,
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              equalHeight: false,
              itemBuilder: (courseAssignment) => NooCourseCard(
                course: courseAssignment.course!,
                isPinned: courseAssignment.isPinned,
                actions: [
                  if (!courseAssignment.isArchived)
                    (
                      label: 'Архивировать курс',
                      icon: Icons.archive,
                      onPressed: () async {
                        await courseNotifier.archiveCourseAssignment(courseAssignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Курс заархивирован')),
                          );
                        }
                      },
                    ),
                  if (courseAssignment.isArchived)
                    (
                      label: 'Разархивировать курс',
                      icon: Icons.unarchive,
                      onPressed: () async {
                        await courseNotifier.unarchiveCourseAssignment(courseAssignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Курс разархивирован')),
                          );
                        }
                      },
                    ),
                  if (!courseAssignment.isPinned)
                    (
                      label: 'Закрепить курс',
                      icon: Icons.push_pin,
                      onPressed: () async {
                        await courseNotifier.pinCourseAssignment(courseAssignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Курс закреплен')),
                          );
                        }
                      },
                    ),
                  if (courseAssignment.isPinned)
                    (
                      label: 'Открепить курс',
                      icon: Icons.push_pin_outlined,
                      onPressed: () async {
                        await courseNotifier.unpinCourseAssignment(courseAssignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Курс откреплен')),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        NooPagination(
          currentPage: courseState.currentPage,
          totalPages: courseState.totalPages,
          hasNextPage: courseState.hasNextPage,
          hasPreviousPage: courseState.hasPreviousPage,
          onNextPage: courseNotifier.loadNextPage,
          onPreviousPage: courseNotifier.loadPreviousPage,
          onPageSelected: courseNotifier.goToPage,
          isLoading: courseState.isLoading,
        ),
      ],
    );
  }

  Widget _buildArchivedCoursesTab() {
    final courseState = ref.watch(courseAssignmentsNotifierProvider(true));
    final courseNotifier = ref.read(
      courseAssignmentsNotifierProvider(true).notifier,
    );

    if (courseState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courseState.error != null) {
      return NooErrorView(
        error: courseState.error!,
        onRetry: () => courseNotifier.refreshAssignments(isArchived: true),
      );
    }

    final courses = courseState.assignments;

    if (courses.isEmpty) {
      return const NooEmptyList(
        title: 'Нет архивных курсов',
        message: 'У вас нет архивных курсов',
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                courseNotifier.refreshAssignments(isArchived: true),
            child: NooResponsiveCardsGrid<CourseAssignmentEntity>(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              items: courses,
              equalHeight: false,
              itemBuilder: (courseAssignment) => NooCourseCard(
                course: courseAssignment.course!,
                isPinned: courseAssignment.isPinned,
                actions: [
                  if (!courseAssignment.isArchived)
                    (
                      label: 'Архивировать курс',
                      icon: Icons.archive,
                      onPressed: () async {
                        await courseNotifier.archiveCourseAssignment(courseAssignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Курс заархивирован')),
                          );
                        }
                      },
                    ),
                  if (courseAssignment.isArchived)
                    (
                      label: 'Разархивировать курс',
                      icon: Icons.unarchive,
                      onPressed: () async {
                        await courseNotifier.unarchiveCourseAssignment(courseAssignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Курс разархивирован')),
                          );
                        }
                      },
                    ),
                  if (!courseAssignment.isPinned)
                    (
                      label: 'Закрепить курс',
                      icon: Icons.push_pin,
                      onPressed: () async {
                        await courseNotifier.pinCourseAssignment(courseAssignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Курс закреплен')),
                          );
                        }
                      },
                    ),
                  if (courseAssignment.isPinned)
                    (
                      label: 'Открепить курс',
                      icon: Icons.push_pin_outlined,
                      onPressed: () async {
                        await courseNotifier.unpinCourseAssignment(courseAssignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Курс откреплен')),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        NooPagination(
          currentPage: courseState.currentPage,
          totalPages: courseState.totalPages,
          hasNextPage: courseState.hasNextPage,
          hasPreviousPage: courseState.hasPreviousPage,
          onNextPage: courseNotifier.loadNextPage,
          onPreviousPage: courseNotifier.loadPreviousPage,
          onPageSelected: courseNotifier.goToPage,
          isLoading: courseState.isLoading,
        ),
      ],
    );
  }

  void _onEditCourse(CourseEntity course) {
    // TODO: Implement edit course functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Редактирование курса: ${course.name}')),
    );
  }

  void _onDeleteCourse(CourseEntity course) {
    // TODO: Implement delete course functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Удаление курса: ${course.name}')));
  }

  void _onRestoreCourse(CourseEntity course) {
    // TODO: Implement restore course functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Восстановление курса: ${course.name}')),
    );
  }
}
