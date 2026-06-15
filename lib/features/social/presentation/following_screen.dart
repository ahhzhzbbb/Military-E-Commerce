import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/user.dart';
import 'package:provider/provider.dart';
import '../data/follow_provider.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FollowProvider>();
      provider.loadFollowing();
      provider.loadFollowers();
      provider.loadBlocked();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách theo dõi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Đang theo dõi'),
            Tab(text: 'Người theo dõi'),
            Tab(text: 'Đã chặn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList<FollowProvider>(
            selector: (p) => p.following,
            emptyIcon: Icons.person_add_outlined,
            emptyTitle: 'Chưa theo dõi ai',
            showFollowButton: true,
          ),
          _buildUserList<FollowProvider>(
            selector: (p) => p.followers,
            emptyIcon: Icons.people_outline,
            emptyTitle: 'Chưa có người theo dõi',
            showFollowButton: false,
          ),
          _buildUserList<FollowProvider>(
            selector: (p) => p.blocked,
            emptyIcon: Icons.block,
            emptyTitle: 'Chưa chặn ai',
            showFollowButton: false,
            isBlockList: true,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList<T extends FollowProvider>({
    required List<User> Function(FollowProvider) selector,
    required IconData emptyIcon,
    required String emptyTitle,
    required bool showFollowButton,
    bool isBlockList = false,
  }) {
    return Consumer<FollowProvider>(
      builder: (context, provider, child) {
        final users = selector(provider);

        if (provider.isLoading && users.isEmpty) {
          return const LoadingIndicator(message: 'Đang tải...');
        }

        if (users.isEmpty) {
          return EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (isBlockList) {
              await provider.loadBlocked();
            } else if (showFollowButton) {
              await provider.loadFollowing();
            } else {
              await provider.loadFollowers();
            }
          },
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserItem(provider, user, showFollowButton, isBlockList);
            },
          ),
        );
      },
    );
  }

  Widget _buildUserItem(FollowProvider provider, User user, bool showFollowButton, bool isBlockList) {
    final isFollowed = provider.isFollowing(user.id);

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: user.avatar != null
            ? ClipOval(
                child: CustomNetworkImage(
                  imageUrl: user.avatar,
                  width: 48,
                  height: 48,
                ),
              )
            : const Icon(Icons.person, color: AppColors.primary),
      ),
      title: Text(
        user.username ?? 'Người dùng',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: user.address != null
          ? Text(
              user.address!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isBlockList
          ? TextButton(
              onPressed: () => provider.toggleBlock(user.id),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Bỏ chặn'),
            )
          : showFollowButton
              ? OutlinedButton(
                  onPressed: () => provider.toggleFollow(user.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isFollowed ? AppColors.textSecondary : AppColors.primary,
                    side: BorderSide(
                      color: isFollowed ? AppColors.divider : AppColors.primary,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(isFollowed ? 'Đang theo dõi' : 'Theo dõi'),
                )
              : null,
    );
  }
}
