import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../foundation_home_page.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// The app's [GoRouter].
///
/// An auth-driven `redirect` + `refreshListenable` will be added with the auth
/// feature (see the architecture doc §8). For now it exposes a single
/// placeholder route so the shell is runnable.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const FoundationHomePage(),
      ),
    ],
  );
}
