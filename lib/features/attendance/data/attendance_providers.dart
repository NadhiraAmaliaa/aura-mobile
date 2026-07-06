import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/core_providers.dart';
import '../domain/repositories/attendance_repository.dart';
import 'datasources/attendance_api.dart';
import 'repositories/attendance_repository_impl.dart';

part 'attendance_providers.g.dart';

/// Retrofit attendance client bound to the shared Dio instance.
@riverpod
AttendanceApi attendanceApi(Ref ref) => AttendanceApi(ref.watch(dioProvider));

/// The attendance repository seam consumed by the presentation layer.
@riverpod
AttendanceRepository attendanceRepository(Ref ref) =>
    AttendanceRepositoryImpl(ref.watch(attendanceApiProvider));
