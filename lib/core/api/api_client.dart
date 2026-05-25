import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

// This file defines the ApiClient class, which is responsible for making API requests, handling authentication tokens, and processing responses. It provides methods for GET and POST requests, as well as token management functions.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _accessToken;

  Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  bool get isLoggedIn => _accessToken != null;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Network error: ${e.toString()}',
        code: -1,
      );
    }
  }

  Future<ApiResponse> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http.get(uri, headers: _headers);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Network error: ${e.toString()}',
        code: -1,
      );
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      // Handle code as both string and int (API returns "1000" as string)
      final codeValue = data['code'];
      final code = codeValue is int
          ? codeValue
          : int.tryParse(codeValue.toString()) ?? -1;
      final message = data['message'] as String? ?? '';
      final responseData = data['data'];

      if (code == ResponseCodes.ok || code == ResponseCodes.noData) {
        return ApiResponse(
          isSuccess: true,
          message: message,
          code: code,
          data: responseData,
        );
      } else if (code == ResponseCodes.tokenInvalid) {
        return ApiResponse(
          isSuccess: false,
          message: message,
          code: code,
          data: responseData,
          isTokenExpired: true,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: message,
          code: code,
          data: responseData,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Failed to parse response',
        code: -1,
      );
    }
  }
}

class ApiResponse {
  final bool isSuccess;
  final String message;
  final int code;
  final dynamic data;
  final bool isTokenExpired;

  ApiResponse({
    required this.isSuccess,
    required this.message,
    required this.code,
    this.data,
    this.isTokenExpired = false,
  });

  T? getData<T>() {
    if (data == null) return null;
    if (data is T) return data as T;
    return null;
  }

  Map<String, dynamic>? getDataAsMap() {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<dynamic>? getDataAsList() {
    if (data == null) return null;
    if (data is List<dynamic>) return data;
    return null;
  }
}
