class QueryParams {
  static Map<String, dynamic>? flatten(Map<String, dynamic>? params) {
    if (params == null) return null;
    final result = <String, dynamic>{};
    params.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        result[key] = 'arr(${value.join('|')})';
      } else if (value is Map &&
          value.containsKey('min') &&
          value.containsKey('max')) {
        result[key] = 'range(${value['min']}|${value['max']})';
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}
