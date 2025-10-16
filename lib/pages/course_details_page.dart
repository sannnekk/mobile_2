import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/core/providers/course_providers.dart';
import 'package:mobile_2/widgets/shared/noo_chapter_tree.dart';
import 'package:mobile_2/widgets/shared/noo_error_view.dart';
import 'package:mobile_2/widgets/shared/noo_loader.dart';
import 'package:mobile_2/widgets/shared/noo_material_viewer.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_parallax_header.dart';
import 'package:mobile_2/widgets/shared/draggable_bottom_sheet.dart';

class CourseDetailsPage extends ConsumerStatefulWidget {
  final String courseSlug;

  const CourseDetailsPage({super.key, required this.courseSlug});

  @override
  ConsumerState<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends ConsumerState<CourseDetailsPage> {
  final bool _panelCollapsed = false;
  final double _panelWidth = 320;
  final ScrollController _scrollController = ScrollController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  String? _previousSelectedMaterialId;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    // Optional: handle sheet changes if needed
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseDetailProvider(widget.courseSlug));
    final notifier = ref.read(courseDetailProvider(widget.courseSlug).notifier);

    // Animate sheet based on material selection
    if (_previousSelectedMaterialId != state.selectedMaterialId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.selectedMaterialId != null) {
          _sheetController.animateTo(
            0.1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _sheetController.animateTo(
            0.85,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
      _previousSelectedMaterialId = state.selectedMaterialId;
    }

    final theme = Theme.of(context);
    final borderColor = theme.dividerColor.withOpacity(0.15);
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 680;
    final headerHeight = isCompact ? 200.0 : width * 0.6;

    Widget body;
    if (state.isLoading && state.course == null) {
      body = const Center(child: NooLoader());
    } else if (state.error != null) {
      body = Center(
        child: NooErrorView(
          error: state.error!,
          onRetry: () => notifier.load(),
        ),
      );
    } else if (state.course != null) {
      final course = state.course!;
      final material = _findMaterial(course, state.selectedMaterialId);
      final path = _materialChapterPath(course, state.selectedMaterialId);

      if (isCompact) {
        body = AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: material == null
              ? _buildEmptyState(theme)
              : MaterialViewer(
                  key: ValueKey(material.id),
                  material: material,
                  path: path,
                  embedded: course.images.isNotEmpty,
                  onToggleReaction: (reaction) =>
                      notifier.toggleReaction(material.id, reaction),
                ),
        );
      } else {
        body = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSidebar(
              course,
              state.selectedMaterialId,
              notifier,
              borderColor,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: material == null
                    ? _buildEmptyState(theme)
                    : MaterialViewer(
                        key: ValueKey(material.id),
                        material: material,
                        path: path,
                        embedded: course.images.isNotEmpty,
                        onToggleReaction: (reaction) =>
                            notifier.toggleReaction(material.id, reaction),
                      ),
              ),
            ),
          ],
        );
      }

      if (course.images.isNotEmpty) {
        body = NooParallaxHeader(
          controller: _scrollController,
          height: headerHeight,
          media: course.images.first,
          contentOverlap: 16.0,
          child: body,
        );
      }
    } else {
      // Fallback case: neither loading, error, nor course present
      body = Center(child: NooTextTitle('Не удалось загрузить курс'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        title: NooTextTitle(
          state.course?.name ?? 'Курс',
          size: NooTitleSize.small,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/courses');
            }
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          body,
          // Only show the sheet when not initially loading
          if (!(state.isLoading && state.course == null))
            DraggableBottomSheet(
              controller: _sheetController,
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.9,
              snap: true,
              snapSizes: const [0.1, 0.85],
              minimizedWidget: NooTextTitle('Материалы'),
              childBuilder: (context, scrollController) {
                if (isCompact && state.course != null) {
                  return ChapterTree(
                    chapters: state.course!.chapters ?? [],
                    selectedMaterialId: state.selectedMaterialId,
                    onSelectMaterial: (id) => notifier.selectMaterial(id),
                    scrollController: scrollController,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          if (state.isLoading && state.course != null)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    CourseEntity course,
    String? selectedMaterialId,
    CourseDetailNotifier notifier,
    Color borderColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _panelCollapsed ? 42 : _panelWidth,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          if (!_panelCollapsed)
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                course.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (!_panelCollapsed) const Divider(height: 1),
          Expanded(
            child: ChapterTree(
              chapters: course.chapters ?? [],
              selectedMaterialId: selectedMaterialId,
              onSelectMaterial: (id) => notifier.selectMaterial(id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Выберите материал',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  CourseMaterialEntity? _findMaterial(CourseEntity course, String? id) {
    if (id == null || course.chapters == null) return null;
    for (final chapter in course.chapters!) {
      final found = _findMaterialInChapter(chapter, id);
      if (found != null) return found;
    }
    return null;
  }

  CourseMaterialEntity? _findMaterialInChapter(
    CourseChapterEntity chapter,
    String id,
  ) {
    for (final material in chapter.materials) {
      if (material.id == id) return material;
    }
    for (final subChapter in chapter.chapters) {
      final found = _findMaterialInChapter(subChapter, id);
      if (found != null) return found;
    }
    return null;
  }

  List<String> _materialChapterPath(CourseEntity course, String? materialId) {
    if (materialId == null || course.chapters == null) return const [];
    for (final chapter in course.chapters!) {
      final path = _materialChapterPathInChapter(chapter, materialId, []);
      if (path.isNotEmpty) return path;
    }
    return const [];
  }

  List<String> _materialChapterPathInChapter(
    CourseChapterEntity chapter,
    String materialId,
    List<String> currentPath,
  ) {
    final newPath = [...currentPath, chapter.name];
    for (final material in chapter.materials) {
      if (material.id == materialId) return newPath;
    }
    for (final subChapter in chapter.chapters) {
      final path = _materialChapterPathInChapter(
        subChapter,
        materialId,
        newPath,
      );
      if (path.isNotEmpty) return path;
    }
    return const [];
  }
}
