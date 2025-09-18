import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/widgets/shared/noo_chapter_tree.dart';

class BottomSheetMenu extends StatefulWidget {
  final List<CourseChapterEntity> chapters;
  final String? selectedMaterialId;
  final ValueChanged<String>? onSelectMaterial;
  final String? title;

  const BottomSheetMenu({
    super.key,
    required this.chapters,
    this.selectedMaterialId,
    this.onSelectMaterial,
    this.title,
  });

  static Future<void> show(
    BuildContext context, {
    required List<CourseChapterEntity> chapters,
    String? selectedMaterialId,
    ValueChanged<String>? onSelectMaterial,
    String? title,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => BottomSheetMenu(
        chapters: chapters,
        selectedMaterialId: selectedMaterialId,
        onSelectMaterial: onSelectMaterial != null
            ? (id) {
                onSelectMaterial(id);
                Navigator.of(ctx).pop();
              }
            : null,
        title: title,
      ),
    );
  }

  @override
  State<BottomSheetMenu> createState() => _BottomSheetMenuState();
}

class _BottomSheetMenuState extends State<BottomSheetMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              if (widget.title != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(height: 1),
              ],
              Expanded(
                child: ChapterTree(
                  chapters: widget.chapters,
                  selectedMaterialId: widget.selectedMaterialId,
                  onSelectMaterial: widget.onSelectMaterial,
                  maxDepth: 3,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
