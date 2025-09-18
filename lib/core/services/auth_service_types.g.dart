// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthForgotPasswordRequest _$AuthForgotPasswordRequestFromJson(
  Map<String, dynamic> json,
) => AuthForgotPasswordRequest(json['email'] as String);

Map<String, dynamic> _$AuthForgotPasswordRequestToJson(
  AuthForgotPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};

AuthLoginRequest _$AuthLoginRequestFromJson(Map<String, dynamic> json) =>
    AuthLoginRequest(
      usernameOrEmail: json['usernameOrEmail'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$AuthLoginRequestToJson(AuthLoginRequest instance) =>
    <String, dynamic>{
      'usernameOrEmail': instance.usernameOrEmail,
      'password': instance.password,
    };

AuthLoginResponse _$AuthLoginResponseFromJson(Map<String, dynamic> json) =>
    AuthLoginResponse(
      token: json['token'] as String,
      payload: AuthPayload.fromJson(json['payload'] as Map<String, dynamic>),
      user: UserEntity.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthLoginResponseToJson(AuthLoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'payload': instance.payload,
      'user': instance.user,
    };

AuthRegisterRequest _$AuthRegisterRequestFromJson(Map<String, dynamic> json) =>
    AuthRegisterRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$AuthRegisterRequestToJson(
  AuthRegisterRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'username': instance.username,
  'password': instance.password,
};

CheckUsernameResponse _$CheckUsernameResponseFromJson(
  Map<String, dynamic> json,
) => CheckUsernameResponse(exists: json['exists'] as bool);

Map<String, dynamic> _$CheckUsernameResponseToJson(
  CheckUsernameResponse instance,
) => <String, dynamic>{'exists': instance.exists};
