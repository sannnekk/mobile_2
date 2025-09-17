import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_config.dart';

final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final client = ApiClient();
  await client.init(config: ApiConfig.fromEnv());
  return client;
});
