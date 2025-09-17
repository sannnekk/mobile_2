import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final Map<String, dynamic>? userPayload;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,
    this.token,
    this.userPayload,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    Map<String, dynamic>? userPayload,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      userPayload: userPayload ?? this.userPayload,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  static const _tokenKey = 'api_token';
  static const _payloadKey = 'api_payload';

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final payloadStr = prefs.getString(_payloadKey);

      if (token != null && token.isNotEmpty) {
        Map<String, dynamic>? payload;
        if (payloadStr != null) {
          try {
            payload = Map<String, dynamic>.from(
              Map.castFrom(jsonDecode(payloadStr)),
            );
          } catch (e) {
            // Invalid payload, clear it
            await prefs.remove(_payloadKey);
          }
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          userPayload: payload,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> login(String token, Map<String, dynamic>? payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (payload != null) {
      await prefs.setString(_payloadKey, jsonEncode(payload));
    }

    state = state.copyWith(
      isAuthenticated: true,
      token: token,
      userPayload: payload,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_payloadKey);

    state = state.copyWith(
      isAuthenticated: false,
      token: null,
      userPayload: null,
    );
  }

  Future<void> refreshAuthStatus() async {
    state = state.copyWith(isLoading: true);
    await _checkAuthStatus();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
