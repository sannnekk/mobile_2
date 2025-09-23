/// Utility functions for string manipulation
String? extractUlid(String? input) {
  if (input == null) return null;
  final ulidRegex = RegExp(r'[0123456789ABCDEFGHJKMNPQRSTVWXYZ]{26}');
  final match = ulidRegex.firstMatch(input);
  return match?.group(0);
}
