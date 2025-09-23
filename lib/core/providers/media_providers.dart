import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/services/media_service.dart';

part 'media_providers.g.dart';

@riverpod
Future<MediaService> mediaService(MediaServiceRef ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return MediaService(client: client);
}
