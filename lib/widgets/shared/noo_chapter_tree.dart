import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/course.dart';

class ChapterTree extends StatefulWidget {
  final List<CourseChapterEntity> chapters;
  final String? selectedMaterialId;
  final ValueChanged<String>? onSelectMaterial;
  final int maxDepth;

  const ChapterTree({
    super.key,
    required this.chapters,
    this.selectedMaterialId,
    this.onSelectMaterial,
    this.maxDepth = 3,
  });

  @override
  State<ChapterTree> createState() => _ChapterTreeState();
}

class _ChapterTreeState extends State<ChapterTree> {
  final Map<String, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.chapters.length,
      itemBuilder: (context, index) {
        final chapter = widget.chapters[index];
        return _ChapterTile(
          chapter: chapter,
          isExpanded: _expanded[chapter.id] ?? false,
          selectedMaterialId: widget.selectedMaterialId,
          onToggle: () => setState(() {
            _expanded[chapter.id] = !(_expanded[chapter.id] ?? false);
          }),
          onSelectMaterial: widget.onSelectMaterial,
          maxDepth: widget.maxDepth,
          depth: 0,
        );
      },
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final CourseChapterEntity chapter;
  final bool isExpanded;
  final String? selectedMaterialId;
  final VoidCallback onToggle;
  final ValueChanged<String>? onSelectMaterial;
  final int maxDepth;
  final int depth;

  const _ChapterTile({
    required this.chapter,
    required this.isExpanded,
    required this.selectedMaterialId,
    required this.onToggle,
    required this.onSelectMaterial,
    required this.maxDepth,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasChildren =
        chapter.chapters.isNotEmpty || chapter.materials.isNotEmpty;
    final canExpand = hasChildren && depth < maxDepth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: canExpand ? onToggle : null,
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 + depth * 20.0,
              top: 12,
              bottom: 12,
              right: 16,
            ),
            child: Row(
              children: [
                if (canExpand)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chapter.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: chapter.titleColor ?? theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && canExpand) ...[
          // Materials in this chapter
          ...chapter.materials.map(
            (material) => _MaterialTile(
              material: material,
              isSelected: selectedMaterialId == material.id,
              onSelect: onSelectMaterial != null
                  ? () => onSelectMaterial!(material.id)
                  : null,
              depth: depth + 1,
            ),
          ),
          // Sub-chapters
          ...chapter.chapters.map(
            (subChapter) => _ChapterTile(
              chapter: subChapter,
              isExpanded: false, // Sub-chapters start collapsed
              selectedMaterialId: selectedMaterialId,
              onToggle:
                  () {}, // Sub-chapters don't toggle in this implementation
              onSelectMaterial: onSelectMaterial,
              maxDepth: maxDepth,
              depth: depth + 1,
            ),
          ),
        ],
      ],
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final CourseMaterialEntity material;
  final bool isSelected;
  final VoidCallback? onSelect;
  final int depth;

  const _MaterialTile({
    required this.material,
    required this.isSelected,
    required this.onSelect,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.only(
          left: 44.0 + depth * 20.0,
          top: 8,
          bottom: 8,
          right: 16,
        ),
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        child: Row(
          children: [
            Icon(
              Icons.article,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                material.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
