import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_2/core/entities/course.dart';

class ChapterTree extends StatefulWidget {
  final List<CourseChapterEntity> chapters;
  final String? selectedMaterialId;
  final ValueChanged<String>? onSelectMaterial;
  final int maxDepth;
  final ScrollController? scrollController;

  const ChapterTree({
    super.key,
    required this.chapters,
    this.selectedMaterialId,
    this.onSelectMaterial,
    this.maxDepth = 3,
    this.scrollController,
  });

  @override
  State<ChapterTree> createState() => _ChapterTreeState();
}

class _ChapterTreeState extends State<ChapterTree> {
  final Map<String, bool> _expanded = {};
  // Cache of top-level chapters that are visible (isActive = true)
  late List<CourseChapterEntity> _visibleChapters;

  @override
  void initState() {
    super.initState();
    _recomputeVisibleChapters();
    _initializeExpandedState();
  }

  @override
  void didUpdateWidget(ChapterTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMaterialId != widget.selectedMaterialId ||
        oldWidget.chapters != widget.chapters) {
      _recomputeVisibleChapters();
      _initializeExpandedState();
    }
  }

  void _recomputeVisibleChapters() {
    _visibleChapters = widget.chapters.where((c) => c.isActive).toList();
  }

  void _initializeExpandedState() {
    _expanded.clear();
    if (widget.selectedMaterialId != null) {
      _expandChaptersContainingMaterial(
        widget.chapters,
        widget.selectedMaterialId!,
      );
    }
  }

  void _expandChaptersContainingMaterial(
    List<CourseChapterEntity> chapters,
    String materialId,
  ) {
    for (final chapter in chapters) {
      if (_chapterContainsMaterial(chapter, materialId)) {
        _expanded[chapter.id] = true;
        // Also expand parent chapters recursively
        _expandParentChapters(chapter, materialId);
      }
    }
  }

  void _expandParentChapters(CourseChapterEntity chapter, String materialId) {
    // This is a simplified version - in a real implementation you'd need to traverse up
    // For now, we'll just ensure the current chapter is expanded
  }

  bool _chapterContainsMaterial(
    CourseChapterEntity chapter,
    String materialId,
  ) {
    // Check direct materials
    if (chapter.materials.any(
      (material) => material.isActive && material.id == materialId,
    )) {
      return true;
    }
    // Check sub-chapters recursively
    for (final subChapter in chapter.chapters.where((c) => c.isActive)) {
      if (_chapterContainsMaterial(subChapter, materialId)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      //physics: const NeverScrollableScrollPhysics(),
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      itemCount: _visibleChapters.length,
      itemBuilder: (context, index) {
        final chapter = _visibleChapters[index];
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
          expandedState: _expanded,
          onUpdateExpansion: (chapterId, isExpanded) => setState(() {
            _expanded[chapterId] = isExpanded;
          }),
        );
      },
    );
  }
}

class _ChapterTile extends StatefulWidget {
  final CourseChapterEntity chapter;
  final bool isExpanded;
  final String? selectedMaterialId;
  final VoidCallback onToggle;
  final ValueChanged<String>? onSelectMaterial;
  final int maxDepth;
  final int depth;
  final Map<String, bool> expandedState;
  final void Function(String, bool) onUpdateExpansion;

  const _ChapterTile({
    required this.chapter,
    required this.isExpanded,
    required this.selectedMaterialId,
    required this.onToggle,
    required this.onSelectMaterial,
    required this.maxDepth,
    required this.depth,
    required this.expandedState,
    required this.onUpdateExpansion,
  });

  @override
  State<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<_ChapterTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_ChapterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredMaterials = widget.chapter.materials
        .where((m) => m.isActive)
        .toList();
    final filteredChapters = widget.chapter.chapters
        .where((c) => c.isActive)
        .toList();
    final hasChildren =
        filteredChapters.isNotEmpty || filteredMaterials.isNotEmpty;
    final canExpand = hasChildren && widget.depth < widget.maxDepth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: canExpand ? widget.onToggle : null,
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 + widget.depth * 20.0,
              top: 12,
              bottom: 12,
              right: 16,
            ),
            child: Row(
              children: [
                if (canExpand)
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.chapter.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color:
                          widget.chapter.titleColor ??
                          theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        widget.isExpanded && canExpand
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Materials in this chapter with staggered animation
                    ...filteredMaterials.asMap().entries.map(
                      (entry) => AnimatedMaterialTile(
                        material: entry.value,
                        isSelected: widget.selectedMaterialId == entry.value.id,
                        onSelect: widget.onSelectMaterial != null
                            ? () => widget.onSelectMaterial!(entry.value.id)
                            : null,
                        depth: widget.depth + 1,
                        index: entry.key,
                        isVisible: widget.isExpanded,
                      ),
                    ),
                    // Sub-chapters
                    ...filteredChapters.map(
                      (subChapter) => _ChapterTile(
                        chapter: subChapter,
                        isExpanded:
                            widget.expandedState[subChapter.id] ?? false,
                        selectedMaterialId: widget.selectedMaterialId,
                        onToggle: () => widget.onUpdateExpansion(
                          subChapter.id,
                          !(widget.expandedState[subChapter.id] ?? false),
                        ),
                        onSelectMaterial: widget.onSelectMaterial,
                        maxDepth: widget.maxDepth,
                        depth: widget.depth + 1,
                        expandedState: widget.expandedState,
                        onUpdateExpansion: widget.onUpdateExpansion,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class AnimatedMaterialTile extends StatefulWidget {
  final CourseMaterialEntity material;
  final bool isSelected;
  final VoidCallback? onSelect;
  final int depth;
  final int index;
  final bool isVisible;

  const AnimatedMaterialTile({
    super.key,
    required this.material,
    required this.isSelected,
    required this.onSelect,
    required this.depth,
    required this.index,
    required this.isVisible,
  });

  @override
  State<AnimatedMaterialTile> createState() => _AnimatedMaterialTileState();
}

class _AnimatedMaterialTileState extends State<AnimatedMaterialTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    if (widget.isVisible) {
      Future.delayed(Duration(milliseconds: widget.index * 50), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedMaterialTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVisible != widget.isVisible) {
      if (widget.isVisible) {
        Future.delayed(Duration(milliseconds: widget.index * 50), () {
          if (mounted) {
            _animationController.forward();
          }
        });
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _MaterialTile(
          material: widget.material,
          isSelected: widget.isSelected,
          onSelect: widget.onSelect,
          depth: widget.depth,
        ),
      ),
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

  String _getDisplayText(String? reaction) {
    if (reaction == null) return '';
    switch (reaction) {
      case 'thinking':
        return '🤔';
      case 'check':
        return '✅';
      default:
        return reaction;
    }
  }

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
        //color: isSelected ? theme.colorScheme.secondary : null,
        child: Row(
          children: [
            if (material.workId != null) ...[
              SvgPicture.asset(
                'assets/icons/uni-hat.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
            ],
            //Icon(Icons.article, size: 16, color: theme.colorScheme.onSecondary),
            //const SizedBox(width: 12),
            Expanded(
              child: Text(
                material.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (material.myReaction != null) ...[
              const SizedBox(width: 8),
              Text(
                _getDisplayText(material.myReaction),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
