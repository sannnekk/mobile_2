import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/entities/user.dart';

part 'auth_payload.g.dart';

@JsonSerializable()
class AuthPayload {
  final String userId;
  final String username;
  @JsonKey(
    fromJson: UserEntity.userRoleFromJson,
    toJson: UserEntity.userRoleToJson,
  )
  final UserRole role;

  const AuthPayload({
    required this.userId,
    required this.username,
    required this.role,
  });

  factory AuthPayload.fromJson(Map<String, dynamic> json) =>
      _$AuthPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$AuthPayloadToJson(this);
}
