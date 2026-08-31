import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/home/home_page.dart';
import 'features/profile/profile_page.dart';
import 'features/discover/discover_page.dart';
import 'features/search/live_search_page.dart';
import 'features/chat/chat_page.dart';

class ChatDatingApp extends StatefulWidget {
  const ChatDatingApp({super.key});
  @override State<ChatDatingApp> createState() => _ChatDatingAppState();
}

class _ChatDatingAppState extends State<ChatDatingApp> {
  ThemeMode mode = ThemeMode.system;

  void setTheme(ThemeMode value) => setState(() => mode = value);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/', builder: (_, __) => HomePage(onThemeChanged: setTheme)),
      GoRoute(path: '/discover', builder: (_, __) => const DiscoverPage()),
      GoRoute(path: '/live-search', builder: (_, __) => const LiveSearchPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => ChatPage(conversationId: state.pathParameters['id']!),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'وصل - Chat & Dating',
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: mode,
    routerConfig: router,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
  );
}
