import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobile_2/core/providers/calendar_providers.dart';
import 'package:mobile_2/widgets/shared/calendar_event_card.dart';
import 'package:mobile_2/widgets/shared/noo_empty_list.dart';
import 'package:mobile_2/widgets/shared/noo_loader.dart';
import 'package:mobile_2/widgets/shared/noo_error_view.dart';
import 'package:intl/intl.dart';
import 'package:mobile_2/core/entities/calendar.dart';
import 'package:mobile_2/styles/colors.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color _getEventColor(CalendarEventType type) {
    switch (type) {
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

  List<Color> _getUniqueEventColorsForDay(
    DateTime day,
    List<CalendarEventEntity> events,
  ) {
    final dayEvents = events
        .where((event) => isSameDay(event.date, day))
        .toList();
    final colors = dayEvents
        .map((event) => _getEventColor(event.type))
        .toSet()
        .toList();
    return colors;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Load events for current month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarEventsProvider.notifier).loadEventsForMonth(_focusedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarEventsProvider);

    return Column(
      children: [
        // Calendar widget
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'ru_RU',
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: (day) {
            return calendarState.events.where((event) {
              return isSameDay(event.date, day);
            }).toList();
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final colors = _getUniqueEventColorsForDay(
                day,
                calendarState.events,
              );
              final isSelected = isSameDay(_selectedDay, day);
              final isToday = isSameDay(day, DateTime.now());

              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : isToday
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : null,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSelected || isToday
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (colors.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: colors
                            .take(4)
                            .map(
                              (color) => Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              );
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              ref.read(calendarEventsProvider.notifier).selectDate(selectedDay);
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            ref.read(calendarEventsProvider.notifier).changeMonth(focusedDay);
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextFormatter: (date, locale) =>
                DateFormat.yMMMM('ru').format(date),
          ),
        ),

        const SizedBox(height: 16),

        // Events list for selected day
        Expanded(child: _buildEventsList(calendarState)),
      ],
    );
  }

  Widget _buildEventsList(CalendarEventsState state) {
    if (state.isLoading) {
      return const Center(child: NooLoader());
    }

    if (state.error != null) {
      return NooErrorView(
        error: state.error!,
        onRetry: () {
          ref
              .read(calendarEventsProvider.notifier)
              .loadEventsForMonth(_focusedDay);
        },
      );
    }

    final events = state.eventsForSelectedDate;

    if (events.isEmpty) {
      return NooEmptyList(message: 'На выбранную дату событий нет');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return CalendarEventCard(event: event);
      },
    );
  }
}
