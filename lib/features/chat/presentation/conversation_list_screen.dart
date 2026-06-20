import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/social.dart';
import '../../auth/data/auth_provider.dart';
import 'package:provider/provider.dart';
import '../data/chat_provider.dart';

import 'package:shimmer/shimmer.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chat, child) {
          if (chat.isLoading && chat.conversations.isEmpty) {
            return _buildConversationShimmer();
          }

          if (chat.conversations.isEmpty) {
            return EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'Chưa có tin nhắn',
              message: 'Nhắn tin cho người bán để biết thêm thông tin sản phẩm',
            );
          }

          return RefreshIndicator(
            onRefresh: () => chat.loadConversations(),
            child: ListView.separated(
              itemCount: chat.conversations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation = chat.conversations[index];
                return _buildConversationItem(context, conversation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationShimmer() {
    return ListView(
      children: List.generate(5, (_) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: const ShimmerListTile(),
      )),
    );
  }

  Widget _buildConversationItem(BuildContext context, Conversation conversation) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: conversation.partnerAvatar != null
                ? ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: conversation.partnerAvatar,
                      width: 48,
                      height: 48,
                    ),
                  )
                : const Icon(Icons.person, color: AppColors.primary),
          ),
          if (conversation.lastMessageUnread == true)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
        ],
      ),
      title: Text(
        conversation.partnerName ?? 'Người dùng',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _lastMessageDisplay(conversation),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: conversation.updatedAt != null
          ? Text(
              _formatTime(conversation.updatedAt!),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }
    return '${date.day}/${date.month}';
  }

  String _lastMessageDisplay(Conversation c) {
    final msg = c.lastMessage ?? '';
    final type = c.lastMessageType;
    if (type == 'image') return '[Hình ảnh]';
    if (type == 'video') return '[Video]';
    if (type == 'file') return '[Tệp]';
    if (type == 'product_id') return '[Sản phẩm]';
    return msg;
  }
}

class ChatScreen extends StatefulWidget {
  final Conversation? conversation;
  final int? partnerId;
  final String? partnerName;
  final String? partnerAvatar;

  const ChatScreen({
    super.key,
    this.conversation,
    this.partnerId,
    this.partnerName,
    this.partnerAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  int? get _effectivePartnerId =>
      widget.partnerId ?? int.tryParse(widget.conversation?.partnerId ?? '');

  String? get _effectivePartnerName =>
      widget.partnerName ?? widget.conversation?.partnerName;

  String? get _effectivePartnerAvatar =>
      widget.partnerAvatar ?? widget.conversation?.partnerAvatar;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      final authProvider = context.read<AuthProvider>();
      final pid = _effectivePartnerId;
      if (pid != null) {
        chatProvider.loadMessages(
          partnerId: pid,
          currentUserId: authProvider.user?.id,
        );
        chatProvider.markAsRead(partnerId: pid);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<ChatProvider>().clearCurrentChat();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final partnerId = _effectivePartnerId;
    if (partnerId == null) return;

    final authProvider = context.read<AuthProvider>();
    _messageController.clear();
    context.read<ChatProvider>().sendMessage(
      partnerId: partnerId,
      content: content,
      currentUserId: authProvider.user?.id,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: _effectivePartnerAvatar != null
                  ? ClipOval(
                      child: CustomNetworkImage(
                        imageUrl: _effectivePartnerAvatar,
                        width: 32,
                        height: 32,
                      ),
                    )
                  : const Icon(Icons.person, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 8),
            Text(_effectivePartnerName ?? 'Người dùng'),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, child) {
                if (chat.isLoading && chat.messages.isEmpty) {
                  return _buildMessagesShimmer();
                }

                if (chat.messages.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'Bắt đầu cuộc trò chuyện',
                    message: 'Hãy gửi tin nhắn đầu tiên',
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    final message = chat.messages[index];
                    final isMine = message.isMine ||
                        (currentUserId != null && message.senderId == currentUserId);
                    return _buildMessageBubble(message, isMine);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessagesShimmer() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(6, (i) {
        final isMine = i % 2 == 0;
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(height: 16, width: isMine ? 120.0 : 160.0, color: Colors.white),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMine ? 12 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMine ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.createdAt != null ? _formatMessageTime(message.createdAt!) : '',
              style: TextStyle(
                color: isMine ? Colors.white70 : AppColors.textHint,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
