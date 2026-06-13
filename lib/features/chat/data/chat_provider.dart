import 'package:flutter/material.dart';
import 'package:military_e_commerce/core/api/api_client.dart';
import 'package:military_e_commerce/core/api/api_data.dart';
import 'package:military_e_commerce/core/constants/api_constants.dart';
import 'package:military_e_commerce/models/social.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _conversations.fold(0, (sum, c) => sum + (c.unreadCount ?? 0));

  Future<void> loadConversations({int index = 0, int count = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _apiClient.post(
      ApiConstants.getListConversation,
      body: {'index': index, 'count': count},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _conversations = ApiData.asList(response.data, ['conversations', 'items', 'list'])
          .whereType<Map>()
          .map((item) => Conversation.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      _conversations = [];
      _error = '${response.message} (Code: ${response.code})';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages({
    int? partnerId,
    int? conversationId,
    int index = 0,
    int count = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final body = <String, dynamic>{
      'index': index,
      'count': count,
      if (partnerId != null) 'partner_id': partnerId,
      if (conversationId != null) 'conversation_id': conversationId,
    };

    final response = await _apiClient.post(
      ApiConstants.getConversation,
      body: body,
      requiresAuth: true,
    );

    if (response.isSuccess) {
      _messages = ApiData.asList(response.data, ['messages', 'items', 'list'])
          .whereType<Map>()
          .map((item) => Message.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      _messages = [];
      _error = '${response.message} (Code: ${response.code})';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendMessage({
    required int partnerId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.sendMessage,
      body: {'partner_id': partnerId, 'content': content},
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final data = response.getDataAsMap();
      if (data != null) {
        final newMessage = Message.fromJson(data);
        _messages.add(newMessage);
        notifyListeners();
      }
      return true;
    }
    _error = '${response.message} (Code: ${response.code})';
    notifyListeners();
    return false;
  }

  Future<void> markAsRead({required int partnerId}) async {
    await _apiClient.post(
      ApiConstants.setReadMessage,
      body: {'partner_id': partnerId},
      requiresAuth: true,
    );
  }

  void clearCurrentChat() {
    _messages = [];
    _currentConversation = null;
    notifyListeners();
  }
}
