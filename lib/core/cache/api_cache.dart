import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCache {
  ApiCache._();

  static const String keyPrefix = 'api_cache_v1:';

  static Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(key));
    if (raw == null) {
      _log('MISS', key);
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _log('INVALID', key);
        return null;
      }

      final expiresAt = DateTime.tryParse(decoded['expiresAt']?.toString() ?? '');
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        await prefs.remove(_storageKey(key));
        _log('EXPIRED', key);
        return null;
      }

      _log('HIT', key);
      return decoded['data'];
    } catch (_) {
      await prefs.remove(_storageKey(key));
      _log('INVALID', key);
      return null;
    }
  }

  static Future<void> write(String key, dynamic data, Duration ttl) async {
    final now = DateTime.now();
    final entry = <String, dynamic>{
      'data': data,
      'cachedAt': now.toIso8601String(),
      'expiresAt': now.add(ttl).toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(key), jsonEncode(entry));
    _log('WRITE', key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(key));
    _log('REMOVE', key);
  }

  static Future<void> removeByPrefix(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    final storagePrefix = _storageKey(prefix);
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(storagePrefix))
        .toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
    _log('REMOVE_PREFIX', '$prefix (${keys.length})');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(keyPrefix))
        .toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
    _log('CLEAR_ALL', '${keys.length} entries');
  }

  static String buildKey(
    String namespace,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) {
    final request = <String, dynamic>{
      if (body != null) 'body': body,
      if (queryParams != null) 'query': queryParams,
    };
    return '$namespace:$endpoint:${canonicalJson(request)}';
  }

  static String canonicalJson(dynamic value) {
    return jsonEncode(_canonicalValue(value));
  }

  static String _storageKey(String key) {
    return key.startsWith(keyPrefix) ? key : '$keyPrefix$key';
  }

  static dynamic _canonicalValue(dynamic value) {
    if (value is Map) {
      final result = <String, dynamic>{};
      final entries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      for (final entry in entries) {
        result[entry.key.toString()] = _canonicalValue(entry.value);
      }
      return result;
    }

    if (value is Iterable) {
      return value.map(_canonicalValue).toList();
    }

    return value;
  }

  static void _log(String action, String key) {
    if (kDebugMode) {
      debugPrint('[ApiCache] $action $key');
    }
  }
}
