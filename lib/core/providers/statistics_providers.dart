import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/statistics.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/services/statistics_service.dart';

part 'statistics_providers.g.dart';

@riverpod
Future<StatisticsService> statisticsService(StatisticsServiceRef ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return StatisticsService(client: client);
}

@riverpod
Future<Statistics> userStatistics(
  UserStatisticsRef ref,
  String username,
  StatisticsRequest request,
) async {
  final service = await ref.watch(statisticsServiceProvider.future);
  final response = await service.getStatistics(username, request);
  if (response is ApiSingleResponse<Statistics>) {
    return response.data;
  } else {
    throw Exception('Failed to load statistics');
  }
}
