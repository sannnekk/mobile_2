import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_status_tags.dart';
import 'package:mobile_2/widgets/shared/noo_score_widget.dart';
import 'package:mobile_2/core/utils/date_helpers.dart';

typedef AssignedWorkAction = ({
  String label,
  IconData icon,
  VoidCallback onPressed,
});

class AssignedWorkCard extends StatelessWidget {
  final AssignedWorkEntity work;
  final List<AssignedWorkAction> actions;

  const AssignedWorkCard({
    super.key,
    required this.work,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Work name
        NooTextTitle(
          work.work?.name ?? 'Без названия',
          size: NooTitleSize.small,
        ),

        const SizedBox(height: 8),

        // Statuses row
        NooStatusTags(
          solveStatus: work.solveStatus,
          checkStatus: work.checkStatus,
        ),

        const SizedBox(height: 8),

        // Deadlines
        if (work.solveDeadlineAt != null || work.checkDeadlineAt != null) ...[
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              if (work.solveDeadlineAt != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Решить до ${formatDate(work.solveDeadlineAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              if (work.checkDeadlineAt != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Проверка до ${formatDate(work.checkDeadlineAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Score display
        NooScoreWidget(score: work.score, maxScore: work.maxScore),
      ],
    );

    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      onLongPress: () => _showActionsMenu(context),
      child: SizedBox(
        width: double.infinity,
        child: NooCard(child: cardContent),
      ),
    );
  }

  void _showActionsMenu(BuildContext context) {
    if (actions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) {
          return ListTile(
            leading: Icon(action.icon),
            title: Text(action.label),
            onTap: () {
              Navigator.of(context).pop();
              action.onPressed();
            },
          );
        }).toList(),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    context.go('/assigned_work/${work.id}');
  }
}
