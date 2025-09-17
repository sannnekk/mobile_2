import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/pages/calendar_page.dart';
import '../widgets/shared/noo_app_scaffold.dart';
import '../pages/auth_page.dart';
import '../pages/courses_page.dart';
import '../pages/assigned_works_page.dart';
import '../pages/settings_page.dart';
import '../pages/profile_page.dart';
import '../pages/register_page.dart';
import 'providers/auth_state_provider.dart';

// Global key for router access
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Provider for router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: authState.isLoading
        ? '/splash'
        : (authState.isAuthenticated ? '/courses' : '/auth'),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const Scaffold(body: AuthPage()),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) =>
            const NooAppScaffold(title: 'Курсы', child: CoursesPage()),
      ),
      GoRoute(
        path: '/assigned_works',
        builder: (context, state) =>
            const NooAppScaffold(title: 'Работы', child: AssignedWorksPage()),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const NooAppScaffold(title: 'Настройки', child: SettingsPage()),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) =>
            const NooAppScaffold(title: 'Календарь', child: CalendarPage()),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const NooAppScaffold(title: 'Профиль', child: ProfilePage()),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;

      // Show splash screen while loading
      if (isLoading) {
        return '/splash';
      }

      // If not authenticated and trying to access protected routes
      final protectedRoutes = [
        '/courses',
        '/assigned_works',
        '/settings',
        '/profile',
      ];
      if (!isAuthenticated && protectedRoutes.contains(state.matchedLocation)) {
        return '/auth';
      }

      // If authenticated and trying to access auth routes
      final authRoutes = ['/auth', '/register'];
      if (isAuthenticated && authRoutes.contains(state.matchedLocation)) {
        return '/courses';
      }

      return null;
    },
  );
});
