class ApiData {
  ApiData._();

  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static List<dynamic> asList(dynamic value, [List<String> keys = const []]) {
    if (value is List) return value;

    final map = asMap(value);
    if (map == null) return [];

    for (final key in keys) {
      final item = map[key];
      if (item is List) return item;
    }

    return [];
  }

  static Map<String, dynamic>? mapFrom(
    dynamic value, [
    List<String> keys = const [],
  ]) {
    final map = asMap(value);
    if (map == null) return null;

    for (final key in keys) {
      final nested = asMap(map[key]);
      if (nested != null) return nested;
    }

    return map;
  }
}
