import 'package:flutter/material.dart';

/// Simple central router layer for the app.
///
/// - Use `AppRouter.routes` if you prefer a static `routes` map.
/// - Use `AppRouter.onGenerateRoute` as `onGenerateRoute` for `MaterialApp`.
class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => _HomePage(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    return MaterialPageRoute(
      builder: (_) => _NotFoundPage(name: settings.name),
      settings: settings,
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home page — replace with your widget')),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  final String? name;
  const _NotFoundPage({Key? key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: Text('Route "${name ?? ''}" not found')),
    );
  }
}
