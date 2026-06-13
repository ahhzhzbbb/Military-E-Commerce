import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/models/social.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications({int index = 0, int count = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getNotification,
      body: {'index': index, 'count': count},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _notifications = ApiData.asList(response.data, ['notifications', 'items', 'list'])
          .whereType<Map>()
          .map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      _notifications = [];
      _error = '${response.message} (Code: ${response.code})';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiClient.post(
      ApiConstants.setReadNotification,
      body: {'notification_id': notificationId},
      requiresAuth: true,
    );

    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      final n = _notifications[index];
      _notifications[index] = AppNotification(
        id: n.id,
        type: n.type,
        title: n.title,
        message: n.message,
        image: n.image,
        avatar: n.avatar,
        productId: n.productId,
        group: n.group,
        isRead: true,
        createdAt: n.createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (final n in _notifications.where((n) => !n.isRead)) {
      await markAsRead(n.id);
    }
  }
}
