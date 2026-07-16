import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/leave_providers.dart';
import '../../data/models/leave_models.dart';

part 'leave_detail_notifier.g.dart';

/// Loads a single leave request by id for the detail screen.
///
/// Surfaced as `AsyncValue<LeaveRequestModel>` so the screen renders loading /
/// error / data exhaustively; [refresh] re-fetches with a full loading state.
@riverpod
class LeaveDetailNotifier extends _$LeaveDetailNotifier {
  @override
  Future<LeaveRequestModel> build(int id) => _load();

  /// Re-fetch the request, showing a full loading state.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<LeaveRequestModel> _load() async {
    final result = await ref.read(leaveRepositoryProvider).detail(id);
    return result.fold(
      onSuccess: (request) => request,
      onFailure: (exception) => throw exception,
    );
  }
}
