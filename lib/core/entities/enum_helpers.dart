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

T enumFromString<T>(List<T> values, String json) {
  final camel = kebabToCamel(json);
  return values.firstWhere((e) => e.toString().split('.').last == camel);
}

String enumToString<T>(T enumValue) {
  final camel = enumValue.toString().split('.').last;
  return camelToKebab(camel);
}
