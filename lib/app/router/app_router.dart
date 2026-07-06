import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/attendance/presentation/screens/attendance_dashboard_screen.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';
import '../home_page.dart';
import '../splash_page.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// The app's [GoRouter], driven by [AuthNotifier].
///
/// The redirect is pure and cheap: it only reads the current auth snapshot and
/// returns a path. Re-evaluation is triggered by a [ValueNotifier] bumped
/// whenever the auth state changes (see architecture doc §8).
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      // Session still resolving on cold start -> hold on the splash.
      if (auth.isLoading || !auth.hasValue) {
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      final isAuthenticated = auth.value is Authenticated;
      final atLogin = location == RoutePaths.login;
      final atSplash = location == RoutePaths.splash;

      if (!isAuthenticated) {
        return atLogin ? null : RoutePaths.login;
      }
      // Authenticated users have no business on splash/login.
      if (atLogin || atSplash) return RoutePaths.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RoutePaths.attendance,
        name: RouteNames.attendance,
        builder: (context, state) => const AttendanceDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.leave,
        name: RouteNames.leave,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Izin',
          icon: Icons.event_busy_outlined,
        ),
      ),
      GoRoute(
        path: RoutePaths.spd,
        name: RouteNames.spd,
        builder: (context, state) => const PlaceholderScreen(
          title: 'SPD',
          icon: Icons.card_travel_outlined,
        ),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Profil',
          icon: Icons.person_outline,
        ),
      ),
    ],
  );
}
