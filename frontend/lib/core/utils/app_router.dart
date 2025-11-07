import 'package:flutter/material.dart';
import 'package:frontend/core/utils/go_router_refresh_stream.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/auth_screen.dart';
import '../../presentation/screens/home_screen.dart';
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
        builder: (context, state) => AuthTestScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => AuthTestScreen(), // позже на отдельный экран
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      // wait for load token
      if (!authState.isInitialized) return null;

      final isLoggedIn = authState.token != null;
      final isAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // if token exist - /home
      if (isLoggedIn && isAuthPage) {
        return '/home';
      }

      // if token doesn't exist - /login
      if (!isLoggedIn && state.matchedLocation == '/home') {
        return '/login';
      }

      return null;
    },
  );
});