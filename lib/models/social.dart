import 'package:military_e_commerce/core/utils/parse_utils.dart';

class Comment {
  final String id;
  final String? productId;
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final int? likeCount;
  final bool? isLiked;
  final DateTime? createdAt;
  final List<Comment>? replies;

  Comment({
    required this.id,
    this.productId,
    this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.likeCount,
    this.isLiked,
    this.createdAt,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString(),
      userId: json['user_id']?.toString(),
      userName: json['user_name'] ?? json['username'] ?? json['name'],
      userAvatar: json['user_avatar'] ?? json['avatar'],
      content: json['content'] ?? '',
      likeCount: toInt(json['like_count'] ?? json['like']),
      isLiked: toBool(json['is_liked']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      replies: (json['replies'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((e) => Comment.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'like_count': likeCount,
      'is_liked': isLiked,
      'created_at': createdAt?.toIso8601String(),
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }
}

class Rating {
  final String id;
  final String? productId;
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final int stars;
  final String? comment;
  final DateTime? createdAt;

  Rating({
    required this.id,
    this.productId,
    this.userId,
    this.userName,
    this.userAvatar,
    required this.stars,
    this.comment,
    this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString(),
      userId: json['user_id']?.toString(),
      userName: json['user_name'] ?? json['username'] ?? json['name'],
      userAvatar: json['user_avatar'] ?? json['avatar'],
      stars: toInt(json['stars'] ?? json['rating'] ?? json['level']) ?? 0,
      comment: json['comment'] ?? json['content'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : (json['created'] != null
              ? DateTime.tryParse(json['created'].toString())
              : null),
    );
  }
}

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String? message;
  final String? image;
  final String? avatar;
  final int? productId;
  final int? group;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    this.image,
    this.avatar,
    this.productId,
    this.group,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'],
      image: json['image'],
      avatar: json['avatar'],
      productId: toInt(json['product_id']),
      group: toInt(json['group']),
      isRead: toBool(json['read'] ?? json['is_read']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class Conversation {
  final String id;
  final String? partnerId;
  final String? partnerName;
  final String? partnerAvatar;
  final String? productId;
  final String? productTitle;
  final String? productImage;
  final String? lastMessage;
  final int? unreadCount;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    this.partnerId,
    this.partnerName,
    this.partnerAvatar,
    this.productId,
    this.productTitle,
    this.productImage,
    this.lastMessage,
    this.unreadCount,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      partnerId: json['partner_id']?.toString(),
      partnerName: json['partner_name'] ?? json['username'],
      partnerAvatar: json['partner_avatar'] ?? json['avatar'],
      productId: json['product_id']?.toString(),
      productTitle: json['product_title'],
      productImage: json['product_image'],
      lastMessage: json['last_message'],
      unreadCount: toInt(json['unread_count']),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String? receiverId;
  final String content;
  final bool isRead;
  final DateTime? createdAt;
  final bool isMine;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.receiverId,
    required this.content,
    this.isRead = false,
    this.createdAt,
    this.isMine = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? json['user_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString(),
      content: json['content'] ?? '',
      isRead: toBool(json['is_read']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isMine: currentUserId != null &&
          json['sender_id']?.toString() == currentUserId,
    );
  }
}

class WalletBalance {
  final double availableBalance;
  final double pendingBalance;
  final double totalBalance;

  WalletBalance({
    this.availableBalance = 0,
    this.pendingBalance = 0,
    this.totalBalance = 0,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    final available =
        toDouble(
          json['available_balance'] ??
              json['available'] ??
              json['balance'] ??
              json['current_balance'],
        ) ??
        0;
    final pending = toDouble(json['pending_balance'] ?? json['pending']) ?? 0;
    return WalletBalance(
      availableBalance: available,
      pendingBalance: pending,
      totalBalance: toDouble(json['total_balance']) ?? available + pending,
    );
  }
}

class BalanceTransaction {
  final String id;
  final String type;
  final String? typeName;
  final double amount;
  final String? description;
  final double? balanceAfter;
  final DateTime? createdAt;

  BalanceTransaction({
    required this.id,
    required this.type,
    this.typeName,
    required this.amount,
    this.description,
    this.balanceAfter,
    this.createdAt,
  });

  factory BalanceTransaction.fromJson(Map<String, dynamic> json) {
    return BalanceTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      typeName: json['type_name'],
      amount: toDouble(json['amount']) ?? 0,
      description: json['description'],
      balanceAfter: toDouble(json['balance_after']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class SavedSearch {
  final String id;
  final String keyword;
  final DateTime? createdAt;

  SavedSearch({required this.id, required this.keyword, this.createdAt});

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id']?.toString() ?? '',
      keyword: json['keyword'] ?? json['search'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class NewsItem {
  final String id;
  final String? title;
  final String? content;
  final DateTime? createdAt;

  NewsItem({required this.id, this.title, this.content, this.createdAt});

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      content: json['content']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
