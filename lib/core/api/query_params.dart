/// Base class for typed query parameters
abstract class QueryParam {
  const QueryParam();

  /// Convert the parameter to its string representation for URL encoding
  String toQueryString();
}

/// Simple string parameter
class StringParam extends QueryParam {
  final String value;

  const StringParam(this.value);

  @override
  String toQueryString() => value;
}

/// Integer parameter
class IntParam extends QueryParam {
  final int value;

  const IntParam(this.value);

  @override
  String toQueryString() => value.toString();
}

/// Boolean parameter
class BoolParam extends QueryParam {
  final bool value;

  const BoolParam(this.value);

  @override
  String toQueryString() => value.toString();
}

/// Array parameter (encoded as 'arr(value1|value2|value3)')
class ArrayParam<T> extends QueryParam {
  final List<T> values;

  const ArrayParam(this.values);

  @override
  String toQueryString() => 'arr(${values.join('|')})';
}

/// Range parameter (encoded as 'range(min|max)')
class RangeParam<T> extends QueryParam {
  final T min;
  final T max;

  const RangeParam(this.min, this.max);

  @override
  String toQueryString() => 'range($min|$max)';
}

/// Filter parameter (encoded as 'filter[key]=value')
class FilterParam extends QueryParam {
  final String key;
  final String value;

  const FilterParam(this.key, this.value);

  @override
  String toQueryString() => value;
}

/// Collection of query parameters
class QueryParams {
  final Map<String, QueryParam> _params;

  const QueryParams(this._params);

  const QueryParams.empty() : _params = const {};

  QueryParams add(String key, QueryParam param) {
    return QueryParams({..._params, key: param});
  }

  QueryParams addAll(Map<String, QueryParam> params) {
    return QueryParams({..._params, ...params});
  }

  /// Add a filter parameter in a type-safe way
  QueryParams addFilter(String filterKey, QueryParam value) {
    return add('filter[$filterKey]', value);
  }

  QueryParams addBoolFilter(String filterKey, bool value) {
    return addFilter(filterKey, BoolParam(value));
  }

  QueryParams addStringFilter(String filterKey, String value) {
    return addFilter(filterKey, StringParam(value));
  }

  QueryParams addIntFilter(String filterKey, int value) {
    return addFilter(filterKey, IntParam(value));
  }

  QueryParams addArrayFilter<T>(String filterKey, List<T> values) {
    return addFilter(filterKey, ArrayParam(values));
  }

  QueryParams addRangeFilter<T>(String filterKey, T min, T max) {
    return addFilter(filterKey, RangeParam(min, max));
  }

  QueryParams addPage(int page) {
    return add('page', IntParam(page));
  }

  QueryParams addLimit(int limit) {
    return add('limit', IntParam(limit));
  }

  QueryParams addSearch(String query) {
    return add('q', StringParam(query));
  }

  QueryParam? get(String key) => _params[key];

  bool get isEmpty => _params.isEmpty;

  bool get isNotEmpty => _params.isNotEmpty;

  /// Convert to the flattened map format expected by the API client
  Map<String, dynamic>? toMap() {
    if (_params.isEmpty) return null;

    final result = <String, dynamic>{};
    _params.forEach((key, param) {
      final value = param.toQueryString();
      if (value.isNotEmpty) {
        result[key] = value;
      }
    });
    return result.isEmpty ? null : result;
  }

  /// Create from a map (for backward compatibility)
  factory QueryParams.fromMap(Map<String, dynamic> map) {
    final params = <String, QueryParam>{};
    map.forEach((key, value) {
      if (value == null) return;

      if (value is String) {
        params[key] = StringParam(value);
      } else if (value is int) {
        params[key] = IntParam(value);
      } else if (value is bool) {
        params[key] = BoolParam(value);
      } else if (value is List) {
        params[key] = ArrayParam(value);
      } else if (value is Map &&
          value.containsKey('min') &&
          value.containsKey('max')) {
        params[key] = RangeParam(value['min'], value['max']);
      } else {
        params[key] = StringParam(value.toString());
      }
    });
    return QueryParams(params);
  }

  @override
  String toString() => 'QueryParams($_params)';
}
