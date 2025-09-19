import 'package:flutter/material.dart';

class NooDraggableBottomSheet extends StatelessWidget {
  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;

  const NooDraggableBottomSheet({
    super.key,
    required this.builder,
    this.initialChildSize = 0.08, // Minimum visible size for easy access
    this.minChildSize = 0.08, // Always keep at least 8% visible
    this.maxChildSize = 0.85,
    this.snapSizes = const [0.08, 0.85], // Snap points
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: true,
      snapSizes: snapSizes,
      shouldCloseOnMinExtent: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Enhanced drag handle for better touch interaction
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (_) {
                  // Absorb the gesture to prevent it from reaching content below
                },
                child: Container(
                  width: double.infinity,
                  height: 42, // Fixed height for consistent drag area
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      height: 6,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              // Content area with proper scrolling
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: builder(context, ScrollController()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
