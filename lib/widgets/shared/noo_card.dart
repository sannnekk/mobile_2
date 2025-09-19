import 'package:flutter/material.dart';

class NooCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? elevation;
  final VoidCallback? onTap;

  const NooCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Material(
      elevation: elevation ?? 8,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      shadowColor: theme.shadowColor.withOpacity(0.3),
      child: Padding(padding: padding, child: child),
    );
    return Container(
      margin: margin,
      child: onTap != null ? InkWell(onTap: onTap, child: card) : card,
    );
  }
}
