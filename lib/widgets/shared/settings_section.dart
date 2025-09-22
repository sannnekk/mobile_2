import 'package:flutter/material.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SettingsSection({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return NooCard(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NooTextTitle(title, size: NooTitleSize.small, isBold: true),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
