import 'package:json_annotation/json_annotation.dart';

/// Converts enum values from kebab-case (server) to camelCase (Dart) and vice versa.
class KebabCaseEnumConverter<T> implements JsonConverter<T, String> {
  final List<T> values;
  final T Function(String name) byName;

  const KebabCaseEnumConverter(this.values, this.byName);

  @override
  T fromJson(String json) {
    final camel = _kebabToCamel(json);
    return values.firstWhere(
      (e) => e.toString().split('.').last == camel,
      orElse: () => byName(camel),
    );
  }

  @override
  String toJson(T object) {
    final camel = object.toString().split('.').last;
    return _camelToKebab(camel);
  }

  String _kebabToCamel(String kebab) {
    final parts = kebab.split('-');
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }

  String _camelToKebab(String camel) {
    return camel.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => '-${m[1]!.toLowerCase()}',
    );
  }
}
