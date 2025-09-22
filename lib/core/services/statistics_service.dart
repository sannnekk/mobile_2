import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/statistics.dart';

class StatisticsService {
  final ApiClient _client;
  StatisticsService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResponse<Statistics>> getStatistics(
    String username,
    StatisticsRequest request,
  ) async {
    final resp = await _client.post<Statistics>(
      path: '/statistics/$username',
      body: request.toJson(),
      fromJson: (json) =>
          Statistics.fromJson((json as Map).cast<String, dynamic>()),
    );
    return resp;
  }
}
