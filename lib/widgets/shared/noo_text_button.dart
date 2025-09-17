import 'package:flutter/material.dart';

/// A reusable text button widget with no underline and secondary color
class NooTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? style;

  const NooTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = TextStyle(
      color: theme.colorScheme.secondary,
      fontFamily: 'Montserrat',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        textStyle: style ?? defaultStyle,
        foregroundColor: theme.colorScheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
      child: Text(
        label,
        style: (style ?? defaultStyle).copyWith(
          decoration: TextDecoration.none, // Explicitly no underline
        ),
      ),
    );
  }
}
