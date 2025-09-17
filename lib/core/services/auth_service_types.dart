import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/entities/user.dart';

part 'auth_service_types.g.dart';

@JsonSerializable()
class AuthForgotPasswordRequest {
  final String email;
  const AuthForgotPasswordRequest(this.email);

  factory AuthForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthForgotPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AuthForgotPasswordRequestToJson(this);
}

@JsonSerializable()
class AuthLoginRequest {
  final String usernameOrEmail;
  final String password;

  const AuthLoginRequest({
    required this.usernameOrEmail,
    required this.password,
  });

  factory AuthLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthLoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AuthLoginRequestToJson(this);
}

@JsonSerializable()
class AuthLoginResponse {
  final String token;
  final Map<String, dynamic> payload;
  final UserEntity user;

  AuthLoginResponse({
    required this.token,
    required this.payload,
    required this.user,
  });

  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthLoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthLoginResponseToJson(this);
}

@JsonSerializable()
class AuthRegisterRequest {
  final String name;
  final String email;
  final String username;
  final String password;

  const AuthRegisterRequest({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
  });

  factory AuthRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthRegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AuthRegisterRequestToJson(this);
}

@JsonSerializable()
class CheckUsernameResponse {
  final bool exists;
  const CheckUsernameResponse({required this.exists});

  factory CheckUsernameResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckUsernameResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CheckUsernameResponseToJson(this);
}
