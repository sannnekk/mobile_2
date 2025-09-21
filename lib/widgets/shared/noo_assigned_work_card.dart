import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

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
        Row(
          children: [
            _buildStatusChip(
              _getSolveStatusText(work.solveStatus),
              _getSolveStatusColor(work.solveStatus),
            ),
            const SizedBox(width: 8),
            _buildStatusChip(
              _getCheckStatusText(work.checkStatus),
              _getCheckStatusColor(work.checkStatus),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Deadlines
        if (work.solveDeadlineAt != null || work.checkDeadlineAt != null) ...[
          Row(
            children: [
              if (work.solveDeadlineAt != null) ...[
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Решить до ${_formatDate(work.solveDeadlineAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (work.checkDeadlineAt != null) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Проверка до ${_formatDate(work.checkDeadlineAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Score display
        if (work.score != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${work.score}/${work.maxScore}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: work.score! / work.maxScore),
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
      ],
    );

    return GestureDetector(
      onLongPress: () => _showActionsMenu(context),
      child: NooCard(child: cardContent),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getSolveStatusText(AssignedWorkSolveStatus status) {
    switch (status) {
      case AssignedWorkSolveStatus.notStarted:
        return 'Не решена';
      case AssignedWorkSolveStatus.inProgress:
        return 'В процессе';
      case AssignedWorkSolveStatus.madeInDeadline:
        return 'Решена в дедлайн';
      case AssignedWorkSolveStatus.madeAfterDeadline:
        return 'Решена после дедлайна';
    }
  }

  String _getCheckStatusText(AssignedWorkCheckStatus status) {
    switch (status) {
      case AssignedWorkCheckStatus.notChecked:
        return 'Не проверена';
      case AssignedWorkCheckStatus.inProgress:
        return 'Проверяется';
      case AssignedWorkCheckStatus.checkedInDeadline:
        return 'Проверена в дедлайн';
      case AssignedWorkCheckStatus.checkedAfterDeadline:
        return 'Проверена после дедлайна';
      case AssignedWorkCheckStatus.checkedAutomatically:
        return 'Проверена автоматически';
    }
  }

  Color _getSolveStatusColor(AssignedWorkSolveStatus status) {
    switch (status) {
      case AssignedWorkSolveStatus.notStarted:
        return Colors.grey;
      case AssignedWorkSolveStatus.inProgress:
        return Colors.orange;
      case AssignedWorkSolveStatus.madeInDeadline:
        return Colors.green;
      case AssignedWorkSolveStatus.madeAfterDeadline:
        return Colors.red;
    }
  }

  Color _getCheckStatusColor(AssignedWorkCheckStatus status) {
    switch (status) {
      case AssignedWorkCheckStatus.notChecked:
        return Colors.grey;
      case AssignedWorkCheckStatus.inProgress:
        return Colors.blue;
      case AssignedWorkCheckStatus.checkedInDeadline:
        return Colors.green;
      case AssignedWorkCheckStatus.checkedAfterDeadline:
        return Colors.red;
      case AssignedWorkCheckStatus.checkedAutomatically:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy', 'ru').format(date);
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
}
