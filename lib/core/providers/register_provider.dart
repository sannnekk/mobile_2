import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/services/auth_service_types.dart';

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

    try {
      final auth = await ref.read(authServiceProvider.future);
      final response = await auth.register(
        AuthRegisterRequest(
          name: name.trim(),
          username: username.trim(),
          email: email.trim(),
          password: password,
        ),
      );

      if (response is ApiErrorResponse) {
        state = state.copyWith(isLoading: false, error: response.error);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Произошла ошибка при регистрации',
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
