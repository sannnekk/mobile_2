import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/services/auth_service_types.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';

class RegisterState {
  final bool isLoading;
  final String? error;

  const RegisterState({this.isLoading = false, this.error});

  RegisterState copyWith({bool? isLoading, String? error}) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier(this.ref) : super(const RegisterState());

  final Ref ref;

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await ApiResponseHandler.handleCall<void>(() async {
      final auth = await ref.read(authServiceProvider.future);
      return auth.register(
        AuthRegisterRequest(
          name: name.trim(),
          username: username.trim(),
          email: email.trim(),
          password: password,
        ),
      );
    });

    if (result.isSuccess) {
      state = state.copyWith(isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error ?? 'Произошла ошибка при регистрации',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(ref),
);
