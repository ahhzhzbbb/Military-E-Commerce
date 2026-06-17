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
  String? _currentUserId;

  List<User> get following => _following;
  List<User> get followers => _followers;
  List<User> get blocked => _blocked;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFollowing(String userId) => _followStatus[userId] ?? false;

  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  List<User> _parseUsers(dynamic data) {
    return ApiData.asList(data, ['users', 'items', 'list', 'followers', 'following', 'blocks'])
        .whereType<Map>()
        .map((item) => User.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void _parseFollowStatusFromList(List<dynamic> rawList) {
    for (final item in rawList) {
      if (item is Map) {
        final id = item['id']?.toString();
        final followed = item['followed'];
        if (id != null && id.isNotEmpty) {
          if (followed is bool) {
            _followStatus[id] = followed;
          } else if (followed is int) {
            _followStatus[id] = followed != 0;
          } else if (followed is num) {
            _followStatus[id] = followed != 0;
          }
        }
      }
    }
  }

  Future<void> loadFollowing({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final effectiveUserId = userId ?? _currentUserId;
    final body = <String, dynamic>{
      'index': 0,
      'count': 50,
    };
    if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
      body['user_id'] = int.tryParse(effectiveUserId) ?? effectiveUserId;
    }

    final response = await _apiClient.post(
      ApiConstants.getListFollowing,
      body: body,
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final rawList = ApiData.asList(response.data, []);
      _following = _parseUsers(response.data);
      _parseFollowStatusFromList(rawList);
      for (final user in _following) {
        _followStatus[user.id] = true;
      }
    } else {
      _following = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFollowers({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final effectiveUserId = userId ?? _currentUserId;
    final body = <String, dynamic>{
      'index': 0,
      'count': 50,
    };
    if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
      body['user_id'] = int.tryParse(effectiveUserId) ?? effectiveUserId;
    }

    final response = await _apiClient.post(
      ApiConstants.getListFollowed,
      body: body,
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final rawList = ApiData.asList(response.data, []);
      _followers = _parseUsers(response.data);
      _parseFollowStatusFromList(rawList);
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
    final action = isCurrentlyFollowing ? 'unfollow' : 'follow';

    final response = await _apiClient.post(
      ApiConstants.setUserFollow,
      body: {
        'followee_id': int.tryParse(userId) ?? userId,
        'action': action,
      },
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final data = response.getDataAsMap();
      if (data != null) {
        final isNowFollowing = data['is_following'];
        if (isNowFollowing is bool) {
          _followStatus[userId] = isNowFollowing;
        } else {
          _followStatus[userId] = action == 'follow';
        }
      } else {
        _followStatus[userId] = action == 'follow';
      }
      if (_followStatus[userId] == true) {
        if (!_following.any((u) => u.id == userId)) {
          await loadFollowing();
        }
      } else {
        _following.removeWhere((u) => u.id == userId);
      }
      notifyListeners();
      return true;
    }

    if (response.code == ResponseCodes.actionDonePreviously) {
      await loadFollowing();
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> toggleBlock(String userId) async {
    final isCurrentlyBlocked = _blocked.any((u) => u.id == userId);
    final type = isCurrentlyBlocked ? 1 : 0;

    final response = await _apiClient.post(
      ApiConstants.setUserBlock,
      body: {
        'user_id': int.tryParse(userId) ?? userId,
        'type': type,
      },
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
