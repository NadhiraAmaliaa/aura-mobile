/// Centralized route paths and names.
///
/// Feature routes are appended here as features land. See the architecture
/// doc §8.
abstract final class RoutePaths {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/';

  // Main menu destinations (the four v1 features).
  static const String attendance = '/attendance';
  static const String attendanceHistory = 'history';
  static const String attendanceCheckIn = 'check-in';
  static const String leave = '/leave';
  static const String spd = '/spd';
  static const String profile = '/profile';
}

abstract final class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String home = 'home';

  // Main menu destinations (the four v1 features).
  static const String attendance = 'attendance';
  static const String attendanceHistory = 'attendance-history';
  static const String attendanceCheckIn = 'attendance-check-in';
  static const String leave = 'leave';
  static const String spd = 'spd';
  static const String profile = 'profile';
}
