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
  int _numNewMessage = 0;

  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get numNewMessage => _numNewMessage;
  int get unreadCount => _numNewMessage;

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
      final list = ApiData.asList(response.data, []);
      _conversations = list
          .whereType<Map>()
          .map((item) => Conversation.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _numNewMessage = _conversations.where((c) => c.lastMessageUnread == true).length;
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
    String? currentUserId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final body = <String, dynamic>{
      'index': index,
      'count': count,
    };
    if (partnerId != null) body['partner_id'] = partnerId;
    if (conversationId != null) body['conversation_id'] = conversationId;

    final response = await _apiClient.post(
      ApiConstants.getConversation,
      body: body,
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final dataMap = ApiData.mapFrom(response.data, []);
      final messagesList = ApiData.asList(dataMap, ['messages']);
      _messages = messagesList
          .whereType<Map>()
          .map((item) => Message.fromJson(
                Map<String, dynamic>.from(item),
                currentUserId: currentUserId,
              ))
          .toList()
          .reversed
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
    String typeMessage = 'text',
    String? currentUserId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.sendMessage,
      body: {
        'to_id': partnerId,
        'message': content,
        'type_message': typeMessage,
      },
      requiresAuth: true,
    );

    if (response.isSuccess) {
      final data = response.getDataAsMap();
      if (data != null) {
        final createdAtRaw = data['created_at'];
        DateTime? createdAt;
        if (createdAtRaw is num) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(
            (createdAtRaw.toInt()) * 1000,
            isUtc: true,
          );
        }
        final newMessage = Message(
          id: data['message_id']?.toString() ?? '',
          conversationId: data['conversation_id']?.toString() ?? '',
          senderId: currentUserId ?? '',
          content: content,
          type: typeMessage,
          unread: false,
          createdAt: createdAt,
          isMine: true,
        );
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
