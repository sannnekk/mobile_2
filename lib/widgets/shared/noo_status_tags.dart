import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';

class NooStatusTags extends StatelessWidget {
  final AssignedWorkSolveStatus solveStatus;
  final AssignedWorkCheckStatus checkStatus;

  const NooStatusTags({
    super.key,
    required this.solveStatus,
    required this.checkStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildStatusChip(
          _getSolveStatusText(solveStatus),
          _getSolveStatusColor(solveStatus),
        ),
        _buildStatusChip(
          _getCheckStatusText(checkStatus),
          _getCheckStatusColor(checkStatus),
        ),
      ],
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
}
