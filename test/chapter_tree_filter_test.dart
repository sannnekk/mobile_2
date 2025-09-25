import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/widgets/shared/noo_chapter_tree.dart';

void main() {
  group('ChapterTree filtering', () {
    testWidgets('shows only active chapters and materials', (tester) async {
      final activeMaterial = CourseMaterialEntity(
        id: 'm1',
        createdAt: DateTime(2024, 1, 1),
        slug: 'active',
        name: 'Active Material',
      );
      final inactiveMaterial = CourseMaterialEntity(
        id: 'm2',
        createdAt: DateTime(2024, 1, 2),
        slug: 'inactive',
        name: 'Inactive Material',
        isActive: false,
      );

      final activeChapter = CourseChapterEntity(
        id: 'c1',
        createdAt: DateTime(2024, 1, 1),
        name: 'Active Chapter',
        materials: [activeMaterial, inactiveMaterial],
      );
      final inactiveChapter = CourseChapterEntity(
        id: 'c2',
        createdAt: DateTime(2024, 1, 1),
        name: 'Inactive Chapter',
        isActive: false,
        materials: [activeMaterial],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChapterTree(chapters: [activeChapter, inactiveChapter]),
          ),
        ),
      );

      // Only active chapter title should be visible
      expect(find.text('Active Chapter'), findsOneWidget);
      expect(find.text('Inactive Chapter'), findsNothing);

      // Expand the active chapter to reveal materials
      await tester.tap(find.text('Active Chapter'));
      await tester.pumpAndSettle();

      // Only active material should be visible
      expect(find.text('Active Material'), findsOneWidget);
      expect(find.text('Inactive Material'), findsNothing);
    });
  });
}
