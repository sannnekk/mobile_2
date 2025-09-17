import 'package:flutter/material.dart';

enum NooTitleSize { small, medium, large }

class NooTextTitle extends StatelessWidget {
  final String text;
  final NooTitleSize size;
  final TextAlign? align;
  final bool isBold;
  final bool dimmed;
  final Color? color;

  const NooTextTitle(
    this.text, {
    super.key,
    this.size = NooTitleSize.medium,
    this.align,
    this.isBold = true,
    this.dimmed = false,
    this.color,
  });

  double _getFontSize(NooTitleSize size) {
    switch (size) {
      case NooTitleSize.small:
        return 16.0;
      case NooTitleSize.medium:
        return 20.0;
      case NooTitleSize.large:
        return 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: _getFontSize(size),
        fontWeight: isBold ? FontWeight.w800 : FontWeight.normal,
        fontFamily: 'Montserrat',
        color:
            color ??
            (dimmed
                ? theme.textTheme.bodyMedium?.color?.withOpacity(0.6)
                : theme.textTheme.bodyMedium?.color),
      ),
    );
  }
}
