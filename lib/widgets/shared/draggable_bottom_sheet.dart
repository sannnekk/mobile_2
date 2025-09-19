import 'package:flutter/material.dart';

class DraggableBottomSheet extends StatelessWidget {
  final Widget Function(BuildContext, ScrollController) childBuilder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final DraggableScrollableController? controller;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool snap;
  final List<double>? snapSizes;

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: snap,
      snapSizes: snapSizes,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surface,
            borderRadius:
                borderRadius ??
                const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Scrollable(
                viewportBuilder: (context, _) => Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(child: childBuilder(context, scrollController)),
            ],
          ),
        );
      },
    );
  }
}
