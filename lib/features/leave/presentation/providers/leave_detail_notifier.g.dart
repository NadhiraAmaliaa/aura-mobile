// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads a single leave request by id for the detail screen.
///
/// Surfaced as `AsyncValue<LeaveRequestModel>` so the screen renders loading /
/// error / data exhaustively; [refresh] re-fetches with a full loading state.

@ProviderFor(LeaveDetailNotifier)
final leaveDetailProvider = LeaveDetailNotifierFamily._();

/// Loads a single leave request by id for the detail screen.
///
/// Surfaced as `AsyncValue<LeaveRequestModel>` so the screen renders loading /
/// error / data exhaustively; [refresh] re-fetches with a full loading state.
final class LeaveDetailNotifierProvider
    extends $AsyncNotifierProvider<LeaveDetailNotifier, LeaveRequestModel> {
  /// Loads a single leave request by id for the detail screen.
  ///
  /// Surfaced as `AsyncValue<LeaveRequestModel>` so the screen renders loading /
  /// error / data exhaustively; [refresh] re-fetches with a full loading state.
  LeaveDetailNotifierProvider._({
    required LeaveDetailNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'leaveDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leaveDetailNotifierHash();

  @override
  String toString() {
    return r'leaveDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LeaveDetailNotifier create() => LeaveDetailNotifier();

  @override
  bool operator ==(Object other) {
    return other is LeaveDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leaveDetailNotifierHash() =>
    r'4887e40ea4ee4d93153e611ea24ec746931b1229';

/// Loads a single leave request by id for the detail screen.
///
/// Surfaced as `AsyncValue<LeaveRequestModel>` so the screen renders loading /
/// error / data exhaustively; [refresh] re-fetches with a full loading state.

final class LeaveDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          LeaveDetailNotifier,
          AsyncValue<LeaveRequestModel>,
          LeaveRequestModel,
          FutureOr<LeaveRequestModel>,
          int
        > {
  LeaveDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'leaveDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads a single leave request by id for the detail screen.
  ///
  /// Surfaced as `AsyncValue<LeaveRequestModel>` so the screen renders loading /
  /// error / data exhaustively; [refresh] re-fetches with a full loading state.

  LeaveDetailNotifierProvider call(int id) =>
      LeaveDetailNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'leaveDetailProvider';
}

/// Loads a single leave request by id for the detail screen.
///
/// Surfaced as `AsyncValue<LeaveRequestModel>` so the screen renders loading /
/// error / data exhaustively; [refresh] re-fetches with a full loading state.

abstract class _$LeaveDetailNotifier extends $AsyncNotifier<LeaveRequestModel> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  FutureOr<LeaveRequestModel> build(int id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LeaveRequestModel>, LeaveRequestModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LeaveRequestModel>, LeaveRequestModel>,
              AsyncValue<LeaveRequestModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
