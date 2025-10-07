import 'package:flutter/material.dart';

class DraggableBottomSheet extends StatefulWidget {
  final Widget Function(BuildContext, ScrollController) childBuilder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final DraggableScrollableController? controller;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool snap;
  final List<double>? snapSizes;
  final Widget? minimizedWidget;

  const DraggableBottomSheet({
    super.key,
    required this.childBuilder,
    this.initialChildSize = 0.07,
    this.minChildSize = 0.07,
    this.maxChildSize = 0.9,
    this.controller,
    this.backgroundColor,
    this.borderRadius,
    this.snap = false,
    this.snapSizes,
    this.minimizedWidget,
  });

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  late ValueNotifier<double> _sizeNotifier;

  @override
  void initState() {
    super.initState();
    _sizeNotifier = ValueNotifier<double>(widget.initialChildSize);
    if (widget.controller != null) {
      widget.controller!.addListener(_onSizeChanged);
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.removeListener(_onSizeChanged);
    }
    _sizeNotifier.dispose();
    super.dispose();
  }

  void _onSizeChanged() {
    _sizeNotifier.value = widget.controller!.size;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      controller: widget.controller,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: widget.snap,
      snapSizes: widget.snapSizes,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.colorScheme.surface,
            borderRadius:
                widget.borderRadius ??
                const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          // Ensure the sheet respects system insets (e.g., Android gesture/nav bar) and keyboard
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: widget.minimizedWidget != null
                        ? ValueListenableBuilder<double>(
                            valueListenable: _sizeNotifier,
                            builder: (context, size, child) {
                              final switchSize =
                                  (widget.minChildSize + widget.maxChildSize) /
                                  2;
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: size < switchSize
                                    ? SingleChildScrollView(
                                        key: const ValueKey('minimized'),
                                        controller: scrollController,
                                        child: Center(
                                          child: widget.minimizedWidget!,
                                        ),
                                      )
                                    : Container(
                                        key: const ValueKey('expanded'),
                                        child: widget.childBuilder(
                                          context,
                                          scrollController,
                                        ),
                                      ),
                              );
                            },
                          )
                        : widget.childBuilder(context, scrollController),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
