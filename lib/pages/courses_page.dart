import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/core/providers/course_providers.dart';
import 'package:mobile_2/widgets/shared/noo_course_card.dart';
import 'package:mobile_2/widgets/shared/noo_cards_grid.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';
import 'package:mobile_2/widgets/shared/noo_error_view.dart';

class CoursesPage extends ConsumerStatefulWidget {
  const CoursesPage({super.key});

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage>
    with SingleTickerProviderStateMixin {
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
    return RefreshIndicator(
      onRefresh: () => courseNotifier.refreshAssignments(isArchived: false),
      child: NooResponsiveCardsGrid<CourseAssignmentEntity>(
        items: courses,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        equalHeight: false,
        itemBuilder: (courseAssignment) => NooCourseCard(
          course: courseAssignment.course!,
          isPinned: courseAssignment.isPinned,
          actions: [
            (
              label: 'Редактировать',
              icon: Icons.edit,
              onPressed: () => _onEditCourse(courseAssignment.course!),
            ),
            (
              label: 'Удалить',
              icon: Icons.delete,
              onPressed: () => _onDeleteCourse(courseAssignment.course!),
            ),
          ],
        ),
      ),
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
    return RefreshIndicator(
      onRefresh: () => courseNotifier.refreshAssignments(isArchived: true),
      child: NooResponsiveCardsGrid<CourseAssignmentEntity>(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        items: courses,
        equalHeight: false,
        itemBuilder: (courseAssignment) => NooCourseCard(
          course: courseAssignment.course!,
          actions: [
            (
              label: 'Восстановить',
              icon: Icons.restore,
              onPressed: () => _onRestoreCourse(courseAssignment.course!),
            ),
            (
              label: 'Удалить навсегда',
              icon: Icons.delete_forever,
              onPressed: () => _onDeleteCourse(courseAssignment.course!),
            ),
          ],
        ),
      ),
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
