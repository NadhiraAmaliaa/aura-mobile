import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../attendance/presentation/providers/attendance_dashboard_notifier.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_layout.dart';
import '../widgets/home_menu_grid.dart';
import '../widgets/home_motivation_banner.dart';
import '../widgets/home_overview_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // The supplied design is light; keep this palette local to Home.
  static final _theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF174B76),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F8F8),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      authProvider.select((state) {
        final session = state.asData?.value;
        return session is Authenticated ? session.user : null;
      }),
    );
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final avatarUrl = ref.watch(appEnvProvider).resolveAssetUrl(user.avatarUrl);
    final intern = user.intern;
    final gutter = HomeLayout.gutter(MediaQuery.sizeOf(context).width);

    return Theme(
      data: _theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE5EFFB), Color(0xFFF5F8F8)],
                stops: [0, 0.7],
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(attendanceDashboardProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HomeHeader(
                            name: user.name,
                            gutter: gutter,
                            onLogout: () =>
                                ref.read(authProvider.notifier).logout(),
                          ),
                          HomeOverviewCard(
                            name: user.name,
                            avatarUrl: avatarUrl,
                            nim: intern?.nim,
                            division: intern?.division,
                            program: intern?.program ?? intern?.university,
                          ),
                          const SizedBox(height: 20),
                          HomeMenuGrid(
                            onProfile: () => context.push(RoutePaths.profile),
                            onAttendance: () =>
                                context.push(RoutePaths.attendance),
                            onLeave: () => context.push(RoutePaths.leave),
                          ),
                          const SizedBox(height: 16),
                          const HomeMotivationBanner(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
