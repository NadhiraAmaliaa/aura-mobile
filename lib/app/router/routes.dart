/// Centralized route paths and names.
///
/// Feature routes are appended here as features land. See the architecture
/// doc §8.
abstract final class RoutePaths {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String bootstrap = '/bootstrap';
  static const String home = '/';

  // Main menu destinations (the four v1 features).
  static const String attendance = '/attendance';
  static const String attendanceHistory = 'history';
  static const String attendancePresence = 'presence';
  static const String leave = '/leave';
  static const String spd = '/spd';
  static const String profile = '/profile';

  // Leave feature children (relative to `/leave`).
  static const String leavePending = 'pending';
  static const String leaveHistory = 'history';
  static const String leaveDetail = 'detail/:id';
  // Reserved for later slices (submission → S4, letter utility → S5).
  static const String leaveSubmit = 'submit';
  static const String leaveSurat = 'surat-pulang-cepat';

  // Profile feature children (relative to `/profile`).
  static const String profileInternship = 'informasi-magang';
  static const String profileContact = 'kontak';
  static const String profilePassword = 'ganti-password';
}

abstract final class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String bootstrap = 'bootstrap';
  static const String home = 'home';

  // Main menu destinations (the four v1 features).
  static const String attendance = 'attendance';
  static const String attendanceHistory = 'attendance-history';
  static const String attendancePresence = 'attendance-presence';
  static const String leave = 'leave';
  static const String spd = 'spd';
  static const String profile = 'profile';

  // Leave feature children.
  static const String leavePending = 'leave-pending';
  static const String leaveHistory = 'leave-history';
  static const String leaveDetail = 'leave-detail';
  // Reserved for later slices (submission → S4, letter utility → S5).
  static const String leaveSubmit = 'leave-submit';
  static const String leaveSurat = 'leave-surat';

  // Profile feature children.
  static const String profileInternship = 'profile-internship';
  static const String profileContact = 'profile-contact';
  static const String profilePassword = 'profile-password';
}
