import 'package:flutter/material.dart';

class NooScoreWidget extends StatelessWidget {
  final int? score;
  final int maxScore;

  const NooScoreWidget({
    super.key,
    required this.score,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    if (score == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$score/$maxScore',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: score! / maxScore),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) {
            return Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
