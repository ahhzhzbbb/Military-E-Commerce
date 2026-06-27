import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/network/network_status_service.dart';
import 'features/auth/data/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/home/data/product_provider.dart';
import 'features/cart/data/cart_provider.dart';
import 'features/order/data/order_provider.dart';
import 'features/wallet/data/wallet_provider.dart';
import 'features/chat/data/chat_provider.dart';
import 'features/notifications/data/notification_provider.dart';
import 'features/social/data/follow_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _networkStatusService = NetworkStatusService.instance;
  bool _hasSeenOffline = false;

  @override
  void initState() {
    super.initState();
    _networkStatusService.addListener(_handleNetworkStatusChanged);
    _networkStatusService.start();
  }

  @override
  void dispose() {
    _networkStatusService.removeListener(_handleNetworkStatusChanged);
    super.dispose();
  }

  void _handleNetworkStatusChanged() {
    switch (_networkStatusService.status) {
      case NetworkStatus.offline:
        _hasSeenOffline = true;
        _showNetworkSnackBar(
          message: 'Mất kết nối mạng',
          backgroundColor: AppColors.error,
          icon: Icons.wifi_off,
          duration: const Duration(seconds: 4),
        );
        break;
      case NetworkStatus.online:
        if (!_hasSeenOffline) return;
        _showNetworkSnackBar(
          message: 'Đã kết nối mạng trở lại',
          backgroundColor: AppColors.success,
          icon: Icons.wifi,
          duration: const Duration(seconds: 2),
        );
        break;
      case NetworkStatus.unknown:
        break;
    }
  }

  void _showNetworkSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    int retries = 3,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = _scaffoldMessengerKey.currentState;
      if (messenger == null) {
        if (retries <= 0 || !mounted) return;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          _showNetworkSnackBar(
            message: message,
            backgroundColor: backgroundColor,
            icon: icon,
            duration: duration,
            retries: retries - 1,
          );
        });
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            duration: duration,
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: _scaffoldMessengerKey,
        title: 'Shopee thời chiến',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      authProvider.isAuthenticated ? '/home' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Shopee thời chiến',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Leo rank cùng đồng đội',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
