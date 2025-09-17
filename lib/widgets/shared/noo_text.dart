import 'package:flutter/material.dart';

class NooText extends StatelessWidget {
  final String text;
  final bool dimmed;
  final TextAlign? align;

  const NooText(this.text, {super.key, this.dimmed = false, this.align});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Text(
      text,
      textAlign: align,
      style: dimmed
          ? style?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.7),
            )
          : style,
    );
  }
}
