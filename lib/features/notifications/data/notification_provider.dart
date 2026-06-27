import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/models/social.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    final response = await _apiClient.post(
      ApiConstants.getNotification,
      body: {'index': _currentPage, 'count': _pageSize},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final List<AppNotification> fetched = _parseNotificationList(response.data);

      if (refresh) {
        _notifications = fetched;
      } else {
        _notifications.addAll(fetched);
      }

      final badge = _extractBadge(response.data);
      if (badge != null) {
        _unreadCount = badge;
      } else {
        _updateUnreadCountFromList();
      }

      if (fetched.length < _pageSize) {
        _hasMore = false;
      } else {
        _currentPage++;
      }
    } else {
      if (refresh) _notifications = [];
      _error = '${response.message} (Code: ${response.code})';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getNotification,
      body: {'index': _currentPage, 'count': _pageSize},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final List<AppNotification> fetched = _parseNotificationList(response.data);
      _notifications.addAll(fetched);

      final badge = _extractBadge(response.data);
      if (badge != null) {
        _unreadCount = badge;
      }

      if (fetched.length < _pageSize) {
        _hasMore = false;
      } else {
        _currentPage++;
      }
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }

    final response = await _apiClient.post(
      ApiConstants.setReadNotification,
      body: {'notification_id': int.tryParse(notificationId)},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final badge = _extractBadge(response.data);
      if (badge != null) {
        _unreadCount = badge;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _unreadCount = 0;
    notifyListeners();

    for (final n in unread) {
      final response = await _apiClient.post(
        ApiConstants.setReadNotification,
        body: {'notification_id': int.tryParse(n.id)},
        requiresAuth: true,
      );

      if (response.isSuccess) {
        final badge = _extractBadge(response.data);
        if (badge != null) {
          _unreadCount = badge;
          notifyListeners();
        }
      }
    }
  }

  void _updateUnreadCountFromList() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  List<AppNotification> _parseNotificationList(dynamic data) {
    final list = ApiData.asList(data);
    return list.whereType<Map>().map((item) {
      return AppNotification.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  int? _extractBadge(dynamic data) {
    if (data is Map) {
      final badge = data['badge'];
      if (badge is int) return badge;
      if (badge is num) return badge.toInt();
    }
    if (data is Map) {
      final outerData = data['data'];
      if (outerData is Map) {
        final badge = outerData['badge'];
        if (badge is int) return badge;
        if (badge is num) return badge.toInt();
      }
    }
    return null;
  }
}
