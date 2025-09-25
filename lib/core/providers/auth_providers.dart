import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_2/core/providers/api_client_provider.dart';
import 'package:mobile_2/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/entities/auth_payload.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';

part 'auth_providers.g.dart';

@riverpod
Future<AuthService> authService(AuthServiceRef ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return AuthService(client: client);
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final AuthPayload? userPayload;
  final UserEntity? user;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,
    this.token,
    this.userPayload,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    AuthPayload? userPayload,
    UserEntity? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      userPayload: userPayload ?? this.userPayload,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  static const _tokenKey = 'api_token';
  static const _payloadKey = 'api_payload';
  static const _userKey = 'api_user';

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final payloadStr = prefs.getString(_payloadKey);
      final userStr = prefs.getString(_userKey);

      if (token != null && token.isNotEmpty) {
        AuthPayload? payload;
        if (payloadStr != null) {
          try {
            payload = AuthPayload.fromJson(
              (jsonDecode(payloadStr) as Map).cast<String, dynamic>(),
            );
          } catch (e) {
            // Invalid payload, clear it
            await prefs.remove(_payloadKey);
          }
        }
        UserEntity? user;
        if (userStr != null) {
          try {
            user = UserEntity.fromJson(
              (jsonDecode(userStr) as Map).cast<String, dynamic>(),
            );
          } catch (_) {
            await prefs.remove(_userKey);
          }
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          userPayload: payload,
          user: user,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> login(
    String token,
    AuthPayload? payload, {
    UserEntity? user,
  }) async {
    // Ensure ApiClient also knows the token & payload for subsequent API calls
    try {
      final client = await _ref.read(apiClientProvider.future);
      await client.setToken(
        token,
        (payload ?? state.userPayload)?.toJson() ?? {},
      );
    } catch (_) {
      // Fallback to local-only persistence if ApiClient not ready
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (payload != null) {
      await prefs.setString(_payloadKey, jsonEncode(payload.toJson()));
    }
    if (user != null) {
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    }

    state = state.copyWith(
      isAuthenticated: true,
      token: token,
      userPayload: payload,
      user: user ?? state.user,
    );
  }

  Future<void> logout() async {
    // Make DELETE /session/current request in background, ignore failures
    try {
      await ApiResponseHandler.handleCall<void>(() async {
        final authService = await _ref.watch(authServiceProvider.future);
        return authService.logout();
      });
    } catch (_) {
      // Ignore errors as per requirements
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_payloadKey);
    await prefs.remove(_userKey);

    // Clear token from ApiClient as well
    try {
      final client = await _ref.read(apiClientProvider.future);
      await client.clearToken();
    } catch (_) {}

    state = const AuthState(isAuthenticated: false, isLoading: false);
  }

  Future<void> refreshAuthStatus() async {
    state = state.copyWith(isLoading: true);
    await _checkAuthStatus();
  }

  Future<void> updateUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = state.copyWith(user: user);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
