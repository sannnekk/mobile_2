import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/calendar.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/services/calendar_service.dart';

final calendarServiceProvider = FutureProvider<CalendarService>((ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return CalendarService(client: client);
});

class CalendarEventsState {
  final List<CalendarEventEntity> events;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final DateTime focusedMonth;

  const CalendarEventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    required this.selectedDate,
    required this.focusedMonth,
  });

  CalendarEventsState copyWith({
    List<CalendarEventEntity>? events,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    DateTime? focusedMonth,
  }) {
    return CalendarEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
    );
  }

  List<CalendarEventEntity> get eventsForSelectedDate {
    return events.where((event) {
      return event.date.year == selectedDate.year &&
          event.date.month == selectedDate.month &&
          event.date.day == selectedDate.day;
    }).toList();
  }

  List<DateTime> get eventDates {
    return events.map((event) => event.date).toSet().toList();
  }
}

class CalendarEventsNotifier extends StateNotifier<CalendarEventsState> {
  final Ref ref;

  CalendarEventsNotifier(this.ref)
    : super(
        CalendarEventsState(
          selectedDate: DateTime.now(),
          focusedMonth: DateTime.now(),
        ),
      );

  Future<void> loadEventsForMonth(DateTime month) async {
    state = state.copyWith(isLoading: true, error: null, focusedMonth: month);

    try {
      final service = await ref.read(calendarServiceProvider.future);
      final authState = ref.read(authStateProvider);
      final username = authState.user?.username;

      if (username == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }

      // Calculate date range: last day of previous month to last day of current month
      final startDate = DateTime(month.year, month.month - 1, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      final response = await service.getCalendarEvents(
        startDate: startDate,
        endDate: endDate,
        username: username,
      );

      if (response is ApiListResponse<CalendarEventEntity>) {
        state = state.copyWith(events: response.data, isLoading: false);
      } else if (response is ApiErrorResponse) {
        state = state.copyWith(error: response.error, isLoading: false);
      } else {
        state = state.copyWith(error: 'Неизвестная ошибка', isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void changeMonth(DateTime month) {
    if (month.month != state.focusedMonth.month ||
        month.year != state.focusedMonth.year) {
      loadEventsForMonth(month);
    } else {
      state = state.copyWith(focusedMonth: month);
    }
  }
}

final calendarEventsProvider =
    StateNotifierProvider<CalendarEventsNotifier, CalendarEventsState>((ref) {
      return CalendarEventsNotifier(ref);
    });
