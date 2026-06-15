import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/models/user.dart';

class FollowProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<User> _following = [];
  List<User> _followers = [];
  List<User> _blocked = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, bool> _followStatus = {};

  List<User> get following => _following;
  List<User> get followers => _followers;
  List<User> get blocked => _blocked;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFollowing(String userId) => _followStatus[userId] ?? false;

  List<User> _parseUsers(dynamic data) {
    return ApiData.asList(data, ['users', 'items', 'list', 'followers', 'following', 'blocks'])
        .whereType<Map>()
        .map((item) => User.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> loadFollowing() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getListFollowing,
      body: const {'index': 0, 'count': 50},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _following = _parseUsers(response.data);
      for (final user in _following) {
        _followStatus[user.id] = true;
      }
    } else {
      _following = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFollowers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getListFollowed,
      body: const {'index': 0, 'count': 50},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _followers = _parseUsers(response.data);
    } else {
      _followers = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadBlocked() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getListBlocks,
      body: const {'index': 0, 'count': 50},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _blocked = _parseUsers(response.data);
    } else {
      _blocked = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleFollow(String userId) async {
    final isCurrentlyFollowing = isFollowing(userId);

    final response = await _apiClient.post(
      ApiConstants.setUserFollow,
      body: {'user_id': int.tryParse(userId) ?? userId},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _followStatus[userId] = !isCurrentlyFollowing;
      if (!isCurrentlyFollowing) {
        if (!_following.any((u) => u.id == userId)) {
          await loadFollowing();
        }
      } else {
        _following.removeWhere((u) => u.id == userId);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> toggleBlock(String userId) async {
    final response = await _apiClient.post(
      ApiConstants.setUserBlock,
      body: {'user_id': int.tryParse(userId) ?? userId},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      await loadBlocked();
      notifyListeners();
      return true;
    }
    return false;
  }
}
