import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/core_providers.dart';
import 'datasources/leave_api.dart';
import 'repositories/leave_repository.dart';
import 'repositories/leave_repository_impl.dart';

part 'leave_providers.g.dart';

/// Retrofit leave client bound to the shared Dio instance.
@riverpod
LeaveApi leaveApi(Ref ref) => LeaveApi(ref.watch(dioProvider));

/// The leave repository seam consumed by the presentation layer.
@riverpod
LeaveRepository leaveRepository(Ref ref) =>
    LeaveRepositoryImpl(ref.watch(leaveApiProvider));
