import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/services/auth_service_types.dart';

class AuthService {
  final ApiClient _client;
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResponse<AuthLoginResponse>> login(
    AuthLoginRequest req, {
    bool rememberToken = true,
  }) async {
    final resp = await _client.post<AuthLoginResponse>(
      path: '/auth/login',
      body: req.toJson(),
      requireAuth: false,
      fromJson: (json) =>
          AuthLoginResponse.fromJson((json as Map).cast<String, dynamic>()),
    );
    if (resp is ApiSingleResponse<AuthLoginResponse>) {
      if (rememberToken) {
        await _client.setToken(resp.data.token, resp.data.payload);
      }
    }
    return resp;
  }

  Future<ApiResponse<void>> register(AuthRegisterRequest req) async {
    final resp = await _client.post<void>(
      path: '/auth/register',
      body: req.toJson(),
      requireAuth: false,
      acceptEmpty: true,
    );
    if (resp is ApiEmptyResponse) return resp;
    if (resp is ApiSingleResponse) return ApiEmptyResponse();
    return resp;
  }

  Future<ApiResponse<CheckUsernameResponse>> checkUsername(
    String usernameToCheck,
  ) async {
    final resp = await _client.get<CheckUsernameResponse>(
      path: '/auth/check-username/$usernameToCheck',
      requireAuth: false,
      fromJson: (json) =>
          CheckUsernameResponse.fromJson((json as Map).cast<String, dynamic>()),
    );
    return resp;
  }

  Future<ApiResponse<void>> forgotPassword(
    AuthForgotPasswordRequest req,
  ) async {
    final resp = await _client.post<void>(
      path: '/auth/forgot-password',
      body: req.toJson(),
      requireAuth: false,
      acceptEmpty: true,
    );
    if (resp is ApiEmptyResponse) return resp;
    if (resp is ApiSingleResponse) return ApiEmptyResponse();
    return resp;
  }
}
