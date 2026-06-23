import 'package:flutter/material.dart';
import 'package:military_e_commerce/features/product/presentation/search_screen.dart';
import 'package:provider/provider.dart';
import '../data/product_provider.dart';
import '../../auth/data/auth_provider.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../chat/presentation/conversation_list_screen.dart';
import '../../chat/data/chat_provider.dart';
import '../../social/data/follow_provider.dart';
import 'pages/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts();
      final userId = context.read<AuthProvider>().user?.id;
      final followProvider = context.read<FollowProvider>();
      followProvider.setCurrentUserId(userId);
      followProvider.loadFollowing();
      followProvider.loadBlocked();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeContent(),
          SearchScreen(),
          ConversationListScreen(),
          CartScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            context.read<ChatProvider>().loadConversations();
          }
          if (index == 4) {
            final userId = context.read<AuthProvider>().user?.id;
            final followProvider = context.read<FollowProvider>();
            followProvider.setCurrentUserId(userId);
            followProvider.loadFollowing();
            followProvider.loadFollowers();
            followProvider.loadBlocked();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
