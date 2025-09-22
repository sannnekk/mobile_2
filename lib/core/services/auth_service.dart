import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/services/auth_service_types.dart';
import 'package:mobile_2/core/entities/user.dart';

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

  Future<ApiResponse<void>> logout() async {
    final resp = await _client.delete<void>(
      path: '/session/current',
      silent: true,
      acceptEmpty: true,
    );
    if (resp is ApiEmptyResponse) return resp;
    if (resp is ApiSingleResponse) return ApiEmptyResponse();
    return resp;
  }

  Future<ApiResponse<UserEntity>> getUser(String username) async {
    final resp = await _client.get<UserEntity>(
      path: '/user/$username',
      fromJson: (json) =>
          UserEntity.fromJson((json as Map).cast<String, dynamic>()),
    );
    return resp;
  }

  Future<ApiResponse<String>> getServerVersion() async {
    final resp = await _client.get<String>(
      path: '/platform/version',
      requireAuth: false,
      fromJson: (json) => json as String,
    );
    return resp;
  }

  Future<ApiResponse<void>> updateUserEmail(
    String userId,
    String newEmail,
  ) async {
    final resp = await _client.patch<void>(
      path: '/user/$userId/email',
      body: {'email': newEmail},
      acceptEmpty: true,
    );
    return resp;
  }

  Future<ApiResponse<void>> updateUserPassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    final resp = await _client.patch<void>(
      path: '/user/$userId',
      body: {
        'id': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
      acceptEmpty: true,
    );
    return resp;
  }

  Future<ApiResponse<void>> updateUserName(String userId, String name) async {
    final resp = await _client.patch<void>(
      path: '/user/$userId',
      body: {'id': userId, 'name': name},
      acceptEmpty: true,
    );
    return resp;
  }

  Future<ApiResponse<void>> updateUserAvatar(
    String userId,
    UserAvatarEntity? avatar,
  ) async {
    final resp = await _client.patch<void>(
      path: '/user/$userId',
      body: {'id': userId, 'avatar': avatar?.toJson()},
      acceptEmpty: true,
    );
    return resp;
  }

  Future<ApiResponse<void>> updateUserTelegramNotifications(
    String userId,
    bool telegramNotificationsEnabled,
  ) async {
    final resp = await _client.patch<void>(
      path: '/user/$userId',
      body: {
        'id': userId,
        'telegramNotificationsEnabled': telegramNotificationsEnabled,
      },
      acceptEmpty: true,
    );
    return resp;
  }

  Future<ApiResponse<void>> deleteUserAccount(
    String userId,
    String password,
  ) async {
    final resp = await _client.delete<void>(
      path: '/user/$userId/$password',
      acceptEmpty: true,
    );
    return resp;
  }
}
