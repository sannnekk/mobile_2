import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/services/auth_service.dart';

final authServiceProvider = FutureProvider<AuthService>((ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return AuthService(client: client);
});
