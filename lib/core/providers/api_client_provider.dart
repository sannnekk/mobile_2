import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_config.dart';

part 'api_client_provider.g.dart';

@riverpod
Future<ApiClient> apiClient(ApiClientRef ref) async {
  final client = ApiClient();
  await client.init(config: ApiConfig.fromEnv());
  return client;
}
