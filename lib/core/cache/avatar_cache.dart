import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AvatarCache {
  AvatarCache._();

  static const _keyPrefix = 'avatar_cache_v1:';

  static String currentUserKey(String userId) {
    return 'current_user:$userId';
  }

  static Future<Uint8List?> read(String key, {String? sourceUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(key));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final cachedUrl = decoded['url']?.toString();
        final data = decoded['data']?.toString();
        if (sourceUrl != null && cachedUrl != sourceUrl) return null;
        if (data == null || data.isEmpty) return null;
        return base64Decode(data);
      }

      if (decoded is String) {
        return base64Decode(decoded);
      }

      return base64Decode(raw);
    } catch (_) {
      await prefs.remove(_storageKey(key));
      return null;
    }
  }

  static Future<void> write(
    String key,
    Uint8List bytes, {
    String? sourceUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey(key),
      jsonEncode({
        'url': sourceUrl,
        'data': base64Encode(bytes),
      }),
    );
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(key));
  }

  static Future<void> cacheFromUrl(String key, String url) async {
    if (url.isEmpty) return;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) return;

    await write(key, response.bodyBytes, sourceUrl: url);
  }

  static String _storageKey(String key) {
    return key.startsWith(_keyPrefix) ? key : '$_keyPrefix$key';
  }
}
