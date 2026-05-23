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
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
      content: json['content'] ?? '',
      likeCount: json['like_count'],
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
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
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
      stars: json['stars'] ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class Notification {
  final String id;
  final String type;
  final String title;
  final String? message;
  final String? image;
  final String? actionId;
  final bool isRead;
  final DateTime? createdAt;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    this.image,
    this.actionId,
    this.isRead = false,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'],
      image: json['image'],
      actionId: json['action_id']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
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
      partnerName: json['partner_name'],
      partnerAvatar: json['partner_avatar'],
      productId: json['product_id']?.toString(),
      productTitle: json['product_title'],
      productImage: json['product_image'],
      lastMessage: json['last_message'],
      unreadCount: json['unread_count'],
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

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.receiverId,
    required this.content,
    this.isRead = false,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString(),
      content: json['content'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
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
    final available = (json['available_balance'] as num?)?.toDouble() ?? 0;
    final pending = (json['pending_balance'] as num?)?.toDouble() ?? 0;
    return WalletBalance(
      availableBalance: available,
      pendingBalance: pending,
      totalBalance: available + pending,
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
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'],
      balanceAfter: (json['balance_after'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}