import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/attendance/presentation/screens/attendance_dashboard_screen.dart';
import '../../features/attendance/presentation/screens/attendance_history_screen.dart';
import '../../features/attendance/presentation/screens/attendance_presence_screen.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/leave/presentation/providers/leave_list_state.dart';
import '../../features/leave/presentation/screens/leave_detail_screen.dart';
import '../../features/leave/presentation/screens/leave_landing_screen.dart';
import '../../features/leave/presentation/screens/leave_list_screen.dart';
import '../../features/leave/presentation/screens/leave_submit_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/contact_edit_screen.dart';
import '../../features/profile/presentation/screens/internship_info_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/surat/presentation/screens/surat_submit_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';
import '../bootstrap/bootstrap_page.dart';
import '../bootstrap/offline_bootstrap_provider.dart';
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
  ref.listen(offlineBootstrapProvider, (_, _) => refresh.value++);
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
      final atBootstrap = location == RoutePaths.bootstrap;

      if (!isAuthenticated) {
        return atLogin ? null : RoutePaths.login;
      }

      // Authenticated, but the minimum offline dataset must be prepared before
      // the app is usable. Hold on the bootstrap page (spinner / retry) until
      // it is ready for this user.
      final bootstrap = ref.read(offlineBootstrapProvider);
      if (!bootstrap.hasValue || bootstrap.hasError) {
        return atBootstrap ? null : RoutePaths.bootstrap;
      }

      // Ready. Authenticated users have no business on splash/login/bootstrap.
      if (atLogin || atSplash || atBootstrap) return RoutePaths.home;
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
        path: RoutePaths.bootstrap,
        name: RouteNames.bootstrap,
        builder: (context, state) => const BootstrapPage(),
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
        routes: [
          GoRoute(
            path: RoutePaths.attendanceHistory,
            name: RouteNames.attendanceHistory,
            builder: (context, state) => const AttendanceHistoryScreen(),
          ),
          GoRoute(
            path: RoutePaths.attendancePresence,
            name: RouteNames.attendancePresence,
            builder: (context, state) => const AttendancePresenceScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.leave,
        name: RouteNames.leave,
        builder: (context, state) => const LeaveLandingScreen(),
        routes: [
          GoRoute(
            path: RoutePaths.leaveSubmit,
            name: RouteNames.leaveSubmit,
            builder: (context, state) => const LeaveSubmitScreen(),
          ),
          GoRoute(
            path: RoutePaths.leavePending,
            name: RouteNames.leavePending,
            builder: (context, state) =>
                const LeaveListScreen(filter: LeaveListFilter.pending),
          ),
          GoRoute(
            path: RoutePaths.leaveHistory,
            name: RouteNames.leaveHistory,
            builder: (context, state) =>
                const LeaveListScreen(filter: LeaveListFilter.history),
          ),
          GoRoute(
            path: RoutePaths.leaveDetail,
            name: RouteNames.leaveDetail,
            builder: (context, state) =>
                LeaveDetailScreen(id: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(
            path: RoutePaths.leaveSurat,
            name: RouteNames.leaveSurat,
            builder: (context, state) => const SuratSubmitScreen(),
          ),
        ],
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
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: RoutePaths.profileInternship,
            name: RouteNames.profileInternship,
            builder: (context, state) => const InternshipInfoScreen(),
          ),
          GoRoute(
            path: RoutePaths.profileContact,
            name: RouteNames.profileContact,
            builder: (context, state) => const ContactEditScreen(),
          ),
          GoRoute(
            path: RoutePaths.profilePassword,
            name: RouteNames.profilePassword,
            builder: (context, state) => const ChangePasswordScreen(),
          ),
        ],
      ),
    ],
  );
}
