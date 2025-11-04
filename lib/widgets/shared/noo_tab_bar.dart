import 'package:flutter/material.dart';

/// A beautiful, reliable custom tab bar widget with proper overflow handling
class NooTabBar extends StatefulWidget {
  final List<Widget> tabs;
  final TabController controller;
  final ValueChanged<int>? onTap;
  final EdgeInsetsGeometry padding;
  final double height;
  final Duration animationDuration;
  final bool expandEvenly;

  const NooTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.height = 50,
    this.animationDuration = const Duration(milliseconds: 280),
    this.expandEvenly = false,
  });

  @override
  State<NooTabBar> createState() => _NooTabBarState();
}

class _NooTabBarState extends State<NooTabBar> {
  @override
  Widget build(BuildContext context) {
    // Always use pill indicator style
    return Container(
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / 2),
      ),
      child: _PillTabBar(
        tabs: widget.tabs,
        controller: widget.controller,
        onTap: widget.onTap,
        animationDuration: widget.animationDuration,
        expandEvenly: widget.expandEvenly,
      ),
    );
  }
}

class _PillTabBar extends StatefulWidget {
  final List<Widget> tabs;
  final TabController controller;
  final ValueChanged<int>? onTap;
  final Duration animationDuration;
  final bool expandEvenly;

  const _PillTabBar({
    required this.tabs,
    required this.controller,
    required this.onTap,
    required this.animationDuration,
    required this.expandEvenly,
  });

  @override
  State<_PillTabBar> createState() => _PillTabBarState();
}

class _PillTabBarState extends State<_PillTabBar>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _tabKeys;
  late List<double> _tabWidths;
  late List<double> _tabPositions;
  late AnimationController _animationController;

  double _indicatorLeft = 0;
  double _indicatorWidth = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeKeys();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    widget.controller.addListener(_onTabControllerChanged);
    widget.controller.animation?.addListener(_onAnimationChanged);
    _scrollController.addListener(_onScrollChanged);
  }

  @override
  void didUpdateWidget(covariant _PillTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _initializeKeys();
    }
  }

  void _initializeKeys() {
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
    _tabWidths = List.filled(widget.tabs.length, 0);
    _tabPositions = List.filled(widget.tabs.length, 0);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabControllerChanged);
    widget.controller.animation?.removeListener(_onAnimationChanged);
    _scrollController.removeListener(_onScrollChanged);
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabControllerChanged() {
    if (mounted) {
      setState(() {});
      _scrollToTab(widget.controller.index);
    }
  }

  void _onAnimationChanged() {
    if (mounted && _isInitialized) {
      _updateIndicatorPosition();
    }
  }

  void _onScrollChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateIndicatorPosition() {
    final animation = widget.controller.animation;
    if (animation == null) return;

    final value = animation.value;
    final fromIndex = value.floor();
    final toIndex = value.ceil();
    final progress = value - fromIndex;

    if (fromIndex >= 0 &&
        fromIndex < _tabPositions.length &&
        toIndex >= 0 &&
        toIndex < _tabPositions.length) {
      final fromLeft = _tabPositions[fromIndex];
      final fromWidth = _tabWidths[fromIndex];
      final toLeft = _tabPositions[toIndex];
      final toWidth = _tabWidths[toIndex];

      final interpolatedLeft = fromLeft + (toLeft - fromLeft) * progress;
      final interpolatedWidth = fromWidth + (toWidth - fromWidth) * progress;

      setState(() {
        _indicatorLeft = interpolatedLeft;
        _indicatorWidth = interpolatedWidth;
      });
    }
  }

  void _scrollToTab(int index) {
    if (!mounted || index >= _tabPositions.length || !_isInitialized) return;

    final tabCenter = _tabPositions[index] + (_tabWidths[index] / 2);
    final screenWidth = MediaQuery.of(context).size.width;
    final scrollOffset = _scrollController.offset;
    final visibleStart = scrollOffset;
    final visibleEnd = scrollOffset + screenWidth;

    // Check if tab is fully visible
    final tabStart = _tabPositions[index];
    final tabEnd = _tabPositions[index] + _tabWidths[index];

    if (tabStart < visibleStart || tabEnd > visibleEnd) {
      // Scroll to center the tab
      final targetOffset = tabCenter - (screenWidth / 2);
      final clampedOffset = targetOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        clampedOffset,
        duration: widget.animationDuration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _updateTabMetrics() {
    if (!mounted) return;

    double currentPosition = 0;
    bool allMeasured = true;

    for (int i = 0; i < _tabKeys.length; i++) {
      final key = _tabKeys[i];
      final context = key.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          _tabWidths[i] = renderBox.size.width;
          _tabPositions[i] = currentPosition;
          currentPosition += renderBox.size.width;
        } else {
          allMeasured = false;
        }
      } else {
        allMeasured = false;
      }
    }

    if (allMeasured && !_isInitialized) {
      setState(() {
        _isInitialized = true;
      });
      _updateIndicatorPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate total width needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateTabMetrics();
        });

        final tabWidgets = List<Widget>.generate(widget.tabs.length, (index) {
          final normalizedChild = _normalizeTabChild(widget.tabs[index]);
          return _PillTab(
            key: _tabKeys[index],
            isSelected: widget.controller.index == index,
            onTap: () {
              widget.controller.animateTo(index);
              widget.onTap?.call(index);
            },
            theme: theme,
            child: normalizedChild,
          );
        });

        final content = widget.expandEvenly
            ? Row(
                children: tabWidgets
                    .map((tab) => Expanded(child: tab))
                    .toList(),
              )
            : Row(children: tabWidgets);

        // Check if scrolling is needed
        final totalWidth = _tabWidths.fold(0.0, (sum, width) => sum + width);
        final needsScrolling =
            totalWidth > constraints.maxWidth && !widget.expandEvenly;

        final scrollableContent = Stack(
          children: [
            // Animated pill indicator (behind content for z-index effect)
            if (_isInitialized)
              AnimatedPositioned(
                duration: widget.animationDuration,
                curve: Curves.easeOutCubic,
                left:
                    _indicatorLeft -
                    (_scrollController.hasClients
                        ? _scrollController.offset
                        : 0),
                width: _indicatorWidth,
                bottom: 4,
                height: 25,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            if (needsScrolling)
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: totalWidth,
                  height: double.infinity,
                  child: content,
                ),
              )
            else
              content,
          ],
        );

        return needsScrolling
            ? scrollableContent
            : Stack(
                children: [
                  if (_isInitialized)
                    Positioned(
                      left: _indicatorLeft,
                      width: _indicatorWidth,
                      bottom: 4,
                      height: 25,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  content,
                ],
              );
      },
    );
  }
}

class _PillTab extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _PillTab({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final resolvedTextStyle =
        (theme.textTheme.labelLarge ?? const TextStyle(fontSize: 14)).copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: textColor,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: IconTheme(
          data: IconThemeData(color: textColor),
          child: DefaultTextStyle(style: resolvedTextStyle, child: child),
        ),
      ),
    );
  }
}

Widget _normalizeTabChild(Widget original) {
  if (original is Tab) {
    if (original.child != null) {
      return original.child!;
    }
    if (original.text != null) {
      return Text(original.text!);
    }
    if (original.icon != null) {
      return original.icon!;
    }
  }
  return original;
}
