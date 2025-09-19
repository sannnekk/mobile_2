import 'package:flutter/material.dart';

class ReactionWidget extends StatelessWidget {
  final String? currentReaction;
  final List<String> availableReactions;
  final Function(String) onToggle;

  const ReactionWidget({
    super.key,
    required this.currentReaction,
    required this.availableReactions,
    required this.onToggle,
  });

  String _getDisplayText(String reaction) {
    switch (reaction) {
      case 'thinking':
        return '🤔';
      case 'check':
        return '✅';
      default:
        return reaction;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: availableReactions.map((reaction) {
        final isSelected = currentReaction == reaction;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () => onToggle(reaction),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.secondary.withOpacity(0.1)
                    : theme.colorScheme.surface,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getDisplayText(reaction),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
