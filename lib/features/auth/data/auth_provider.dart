import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/models/models.dart';
import 'package:military_e_commerce/core/utils/mock_data.dart';

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

  Future<void> checkAuthStatus() async {
    await _apiClient.loadTokens();
    if (_apiClient.isLoggedIn) {
      _status = AuthStatus.authenticated;
      _user = MockData.getMockUser();
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
        body: {
          'phone_number': phoneNumber,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response.isSuccess) {
        final data = response.getDataAsMap();
        print('[Login] Success - Response data: $data');
        
        if (data != null) {
          // API returns 'token', not 'access_token'
          final token = data['token'] as String?;
          
          if (token != null && token.isNotEmpty) {
            await _apiClient.setTokens(token, '');
            _user = MockData.getMockUser();
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
        print('[Login] Error - ${response.message}');
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      print('[Login] Exception: $e');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String phoneNumber,
    required String password,
    required String username,
    String? phone,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.signup,
        body: {
          'phone_number': phoneNumber,
          'password': password,
          'username': username,
          if (phone != null) 'phone': phone,
        },
        requiresAuth: false,
      );

      if (response.isSuccess) {
        _status = AuthStatus.authenticated;
        _user = MockData.getMockUser();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _user = MockData.getMockUser();
      await _apiClient.setTokens('mock_token', 'mock_refresh');
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _apiClient.clearTokens();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? username,
    String? email,
    String? phone,
    String? avatar,
    String? coverImage,
    String? address,
  }) async {
    if (_user == null) return false;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _user = _user!.copyWith(
        username: username ?? _user!.username,
        email: email ?? _user!.email,
        phone: phone ?? _user!.phone,
        avatar: avatar ?? _user!.avatar,
        coverImage: coverImage ?? _user!.coverImage,
        address: address ?? _user!.address,
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}