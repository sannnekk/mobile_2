import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/services/auth_service_types.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'package:mobile_2/core/utils/debouncer.dart';

enum UsernameCheckStatus { initial, checking, available, taken, error }

class UsernameCheckState {
  final UsernameCheckStatus status;
  final String? error;

  const UsernameCheckState({
    this.status = UsernameCheckStatus.initial,
    this.error,
  });

  UsernameCheckState copyWith({UsernameCheckStatus? status, String? error}) {
    return UsernameCheckState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class UsernameCheckNotifier extends StateNotifier<UsernameCheckState> {
  UsernameCheckNotifier(this.ref) : super(const UsernameCheckState());

  final Ref ref;
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: 500),
  );

  void checkUsername(String username) {
    // Cancel previous timer
    _debouncer.cancel();

    // Reset to initial if username is empty or too short
    if (username.trim().isEmpty || username.trim().length < 3) {
      state = const UsernameCheckState();
      return;
    }

    // Set checking status immediately
    state = state.copyWith(status: UsernameCheckStatus.checking);

    // Debounce the API call
    _debouncer.debounce(() async {
      final result = await ApiResponseHandler.handleCall<CheckUsernameResponse>(
        () async {
          final authService = await ref.read(authServiceProvider.future);
          return authService.checkUsername(username.trim());
        },
      );

      if (mounted) {
        if (result.isSuccess && result.data != null) {
          final isAvailable = !result.data!.exists;
          state = state.copyWith(
            status: isAvailable
                ? UsernameCheckStatus.available
                : UsernameCheckStatus.taken,
          );
        } else {
          state = state.copyWith(
            status: UsernameCheckStatus.error,
            error: result.error ?? 'Неизвестная ошибка',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}

final usernameCheckProvider =
    StateNotifierProvider<UsernameCheckNotifier, UsernameCheckState>(
      (ref) => UsernameCheckNotifier(ref),
    );
