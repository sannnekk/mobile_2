import 'package:flutter/material.dart';

class NooCardsGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final bool equalHeight;

  const NooCardsGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 1,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding = const EdgeInsets.all(0),
    this.equalHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!equalHeight) {
      // Use Wrap for variable height cards
      return SingleChildScrollView(
        padding: padding,
        child: Wrap(
          spacing: crossAxisSpacing,
          runSpacing: mainAxisSpacing,
          children: items.map(itemBuilder).toList(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final delegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        );
        return GridView.builder(
          padding: padding,
          gridDelegate: delegate,
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(items[index]),
        );
      },
    );
  }
}

// Responsive version that automatically adjusts columns based on screen size
class NooResponsiveCardsGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final bool equalHeight;

  const NooResponsiveCardsGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding = const EdgeInsets.all(0),
    this.equalHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!equalHeight) {
      // Use Wrap for variable height cards
      return SingleChildScrollView(
        padding: padding,
        child: Wrap(
          spacing: crossAxisSpacing,
          runSpacing: mainAxisSpacing,
          children: items.map(itemBuilder).toList(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine cross axis count based on screen width
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          // Phone: 1 column
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1000) {
          // Tablet: 2 columns
          crossAxisCount = 2;
        } else {
          // Desktop: 3 columns
          crossAxisCount = 3;
        }

        return NooCardsGrid<T>(
          items: items,
          itemBuilder: itemBuilder,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          padding: padding,
          equalHeight: equalHeight,
        );
      },
    );
  }
}
