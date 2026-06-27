import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/cache/api_cache.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/models/models.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  String? _stringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  String? _extractToken(Map<String, dynamic> data) {
    return _stringValue(data['token']) ??
        _stringValue(data['access_token']) ??
        _stringValue(data['accessToken']);
  }

  String _extractRefreshToken(Map<String, dynamic> data) {
    return _stringValue(data['refresh_token']) ??
        _stringValue(data['refreshToken']) ??
        '';
  }

  User? _userFromData(dynamic data) {
    final userMap = ApiData.mapFrom(data, ['user', 'profile']);
    if (userMap == null || userMap.isEmpty) return null;
    if (userMap.length == 1 && userMap.containsKey('token')) return null;
    return User.fromJson(userMap);
  }

  Future<User?> _fetchCurrentUser() async {
    final response = await _apiClient.post(
      ApiConstants.getUserInfo,
      body: <String, dynamic>{},
      requiresAuth: true,
    );

    if (response.isTokenExpired) {
      await _apiClient.clearTokens();
      _status = AuthStatus.unauthenticated;
      return null;
    }

    if (!response.isSuccess) return null;
    final publicUser = _userFromData(response.data);
    final userId = publicUser?.id;
    if (userId == null || userId.isEmpty) return publicUser;

    final privateResponse = await _apiClient.post(
      ApiConstants.getUserInfo,
      body: {'user_id': int.tryParse(userId) ?? userId},
      requiresAuth: true,
    );

    if (privateResponse.isTokenExpired) {
      await _apiClient.clearTokens();
      _status = AuthStatus.unauthenticated;
      return null;
    }

    if (!privateResponse.isSuccess) return publicUser;
    return _userFromData(privateResponse.data) ?? publicUser;
  }

  Future<void> checkAuthStatus() async {
    await _apiClient.loadTokens();
    if (_apiClient.isLoggedIn) {
      _user = await _fetchCurrentUser();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {'phone_number': phoneNumber, 'password': password},
        requiresAuth: false,
      );

      if (response.isSuccess) {
        final data = response.getDataAsMap();

        if (data != null) {
          final token = _extractToken(data);

          if (token != null && token.isNotEmpty) {
            await _apiClient.setTokens(token, _extractRefreshToken(data));
            final fetchedUser = await _fetchCurrentUser();
            _user = fetchedUser ?? _userFromData(data);
            _status = AuthStatus.authenticated;
            notifyListeners();
            return true;
          } else {
            _errorMessage = 'Lỗi: API response không chứa token hợp lệ';
            _status = AuthStatus.error;
            notifyListeners();
            return false;
          }
        } else {
          _errorMessage = 'Lỗi: API response không chứa dữ liệu';
          _status = AuthStatus.error;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = '${response.message} (Code: ${response.code})';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String phoneNumber,
    required String password,
    String? username,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{
        'phone_number': phoneNumber,
        'password': password,
        'uuid': 'flutter_device_${DateTime.now().millisecondsSinceEpoch}',
      };
      final response = await _apiClient.post(
        ApiConstants.signup,
        body: body,
        requiresAuth: false,
      );

      if (response.isSuccess) {
        final data = response.getDataAsMap();
        final token = data != null ? _extractToken(data) : null;

        if (token != null && token.isNotEmpty) {
          await _apiClient.setTokens(token, _extractRefreshToken(data!));
          if (username != null && username.isNotEmpty) {
            await _apiClient.post(
              ApiConstants.changeInfoAfterSignup,
              body: {'username': username},
              requiresAuth: true,
            );
          }
          final fetchedUser = await _fetchCurrentUser();
          _user = fetchedUser ?? _userFromData(data);
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        }

        return login(phoneNumber: phoneNumber, password: password);
      } else {
        _errorMessage = response.message;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _apiClient.post(ApiConstants.logout, requiresAuth: true);
    await _apiClient.clearTokens();
    await ApiCache.clearAll();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final updatedUser = await _fetchCurrentUser();
    if (updatedUser != null) {
      _user = updatedUser;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? username,
    String? email,
    String? phone,
    String? avatar,
    String? coverImage,
    String? address,
    String? firstname,
    String? lastname,
  }) async {
    if (_user == null) return false;

    try {
      final body = <String, dynamic>{
        'username': ?username,
        'email': ?email,
        'phone': ?phone,
        'avatar': ?avatar,
        'cover_image': ?coverImage,
        'address': ?address,
        'firstname': ?firstname,
        'lastname': ?lastname,
      };
      final response = await _apiClient.post(
        ApiConstants.setUserInfo,
        body: body,
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }

      var updatedUser = _userFromData(response.data);
      updatedUser ??= await _fetchCurrentUser();
      _user =
          updatedUser ??
          _user!.copyWith(
            username: username ?? _user!.username,
            email: email ?? _user!.email,
            phone: phone ?? _user!.phone,
            avatar: avatar ?? _user!.avatar,
            coverImage: coverImage ?? _user!.coverImage,
            address: address ?? _user!.address,
            firstname: firstname ?? _user!.firstname,
            lastname: lastname ?? _user!.lastname,
          );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.uploadFileBytes(
      ApiConstants.uploadFile,
      bytes: bytes,
      filename: filename,
    );

    if (!response.isSuccess) {
      _errorMessage = '${response.message} (Code: ${response.code})';
      notifyListeners();
      return null;
    }

    final data = ApiData.asMap(response.data);
    final url = data?['url']?.toString();
    if (url == null || url.isEmpty) {
      _errorMessage = 'Upload did not return an avatar URL';
      notifyListeners();
      return null;
    }

    return url;
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.changePassword,
      body: {'password': oldPassword, 'new_password': newPassword},
      requiresAuth: true,
    );

    if (response.isSuccess) return true;

    _errorMessage = '${response.message} (Code: ${response.code})';
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
