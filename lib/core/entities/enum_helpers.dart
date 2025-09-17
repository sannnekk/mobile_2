// Enum JSON conversion helpers for kebab-case <-> camelCase
import '../entities/user.dart';

String kebabToCamel(String kebab) {
  final parts = kebab.split('-');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

String camelToKebab(String camel) {
  return camel.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (m) => '-${m[1]!.toLowerCase()}',
  );
}

UserRole userRoleFromJson(String json) {
  final camel = kebabToCamel(json);
  return UserRole.values.firstWhere((e) => e.name == camel);
}

String userRoleToJson(UserRole role) => camelToKebab(role.name);

AvatarType avatarTypeFromJson(String json) {
  final camel = kebabToCamel(json);
  return AvatarType.values.firstWhere((e) => e.name == camel);
}

String avatarTypeToJson(AvatarType type) => camelToKebab(type.name);
