import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/calendar.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/core/utils/date_helpers.dart';
import 'package:mobile_2/core/utils/string_utils.dart';
import 'package:mobile_2/styles/colors.dart';
import 'package:mobile_2/core/providers/calendar_providers.dart';
import 'package:mobile_2/core/services/calendar_service.dart';

class CalendarEventCard extends ConsumerWidget {
  final CalendarEventEntity event;

  const CalendarEventCard({super.key, required this.event});

  Color _getEventColor() {
    switch (event.type) {
      case CalendarEventType.studentDeadline:
        return AppColors.danger;
      case CalendarEventType.mentorDeadline:
        return AppColors.secondary;
      case CalendarEventType.workChecked:
        return AppColors.success;
      case CalendarEventType.workMade:
        return AppColors.warning;
      case CalendarEventType.event:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return NooCard(
      onTap: event.url != null
          ? () {
              final ulid = extractUlid(event.url!);
              if (ulid != null) {
                context.go('/assigned_work/$ulid');
              }
            }
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 80,
            decoration: BoxDecoration(
              color: _getEventColor(),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event title
                NooTextTitle(event.title, size: NooTitleSize.small),

                const SizedBox(height: 8),

                // Event description
                Text(
                  event.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 8),

                // Event date and type
                Row(
                  children: [
                    Icon(
                      _getEventIcon(event.type),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${formatDate(event.date)} • ${_getEventTypeLabel(event.type)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    if (event.type == CalendarEventType.event) ...[
                      TextButton(
                        onPressed: () => _deleteEvent(context, ref),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.danger,
                        ),
                        child: const Text(
                          'Удалить',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Username if available
                if (event.username != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Пользователь: ${event.username}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.studentDeadline:
        return Icons.schedule;
      case CalendarEventType.mentorDeadline:
        return Icons.assignment_turned_in;
      case CalendarEventType.workChecked:
        return Icons.check_circle;
      case CalendarEventType.workMade:
        return Icons.create;
      case CalendarEventType.event:
        return Icons.event;
    }
  }

  String _getEventTypeLabel(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.studentDeadline:
        return 'Дедлайн студента';
      case CalendarEventType.mentorDeadline:
        return 'Дедлайн ментора';
      case CalendarEventType.workChecked:
        return 'Работа проверена';
      case CalendarEventType.workMade:
        return 'Работа выполнена';
      case CalendarEventType.event:
        return 'Событие';
    }
  }

  Future<void> _deleteEvent(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить событие'),
        content: const Text('Вы уверены, что хотите удалить это событие?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = CalendarService();
        final response = await service.deleteEvent(event.id);

        if (response is ApiEmptyResponse) {
          // Refresh calendar events
          ref
              .read(calendarEventsProvider.notifier)
              .loadEventsForMonth(
                ref.read(calendarEventsProvider).focusedMonth,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Событие удалено')));
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ошибка при удалении события')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
        }
      }
    }
  }
}
