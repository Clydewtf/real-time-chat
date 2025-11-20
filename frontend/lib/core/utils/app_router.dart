import 'package:flutter/material.dart';
import 'package:frontend/core/utils/go_router_refresh_stream.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dtos/user_dto.dart';
import '../../presentation/screens/chats/chat_details_screen.dart';
import '../../presentation/screens/chats/chats_screen.dart';
import '../../presentation/screens/chats/user_search_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../logic/services/providers.dart';


final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authNotifierProvider.notifier).changes,
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat_details',
        builder: (context, state) {
          final currentUserId = state.extra as String? ?? '';
          final chatId = state.pathParameters['id']!;
          return ChatDetailsScreen(
            chatId: chatId,
            currentUserId: currentUserId,
          );
        },
      ),
      GoRoute(
        name: 'user_search',
        path: '/search',
        builder: (context, state) => const UserSearchScreen(),
      ),
    ],
    redirect: (context, state) {
      // wait for load token
      if (!authState.isInitialized) return null;

      final isLoggedIn = authState.token != null;
      final isAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (state.matchedLocation == '/splash') {
        return isLoggedIn ? '/main' : '/login';
      }

      // if token exist - /main
      if (isLoggedIn && isAuthPage) {
        return '/main';
      }

      // if token doesn't exist - /login
      if (!isLoggedIn && state.matchedLocation == '/main') {
        return '/login';
      }

      return null;
    },
  );
});