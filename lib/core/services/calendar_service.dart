import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/api/query_params.dart';
import 'package:mobile_2/core/entities/calendar.dart';
import 'package:mobile_2/core/entities/enum_helpers.dart';

class CalendarService {
  final ApiClient _client;
  CalendarService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResponse<CalendarEventEntity>> getCalendarEvents({
    required DateTime startDate,
    required DateTime endDate,
    required String username,
  }) async {
    final queryParams = QueryParams.empty()
        .addRangeFilter(
          'date',
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        )
        .addStringFilter('username', username);

    final resp = await _client.get<CalendarEventEntity>(
      path: '/calender',
      queryParams: queryParams,
      fromJson: (json) =>
          CalendarEventEntity.fromJson((json as Map).cast<String, dynamic>()),
      isList: true,
    );
    return resp;
  }

  Future<ApiResponse<CalendarEventEntity>> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required CalendarEventVisibility visibility,
  }) async {
    final body = {
      'title': title,
      'description': description,
      'date': date.toUtc().toIso8601String(),
      'visibility': enumToString(visibility).replaceAll('_', '-'),
    };

    final resp = await _client.post<CalendarEventEntity>(
      path: '/calender',
      body: body,
      fromJson: (json) =>
          CalendarEventEntity.fromJson((json as Map).cast<String, dynamic>()),
    );
    return resp;
  }

  Future<ApiResponse<void>> deleteEvent(String eventId) async {
    final resp = await _client.delete<void>(
      path: '/calender/$eventId',
      fromJson: (_) => null,
    );
    return resp;
  }
}
