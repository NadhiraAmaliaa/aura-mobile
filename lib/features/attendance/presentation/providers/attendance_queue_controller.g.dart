// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_queue_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the offline attendance queue for the UI.
///
/// Every capture is persisted first, then an immediate sync is attempted
/// ("always enqueue, then sync"). The queue is also flushed automatically
/// whenever connectivity is regained. State is the full list of queued entries
/// owned by the current user, newest first, so the UI can show a pending badge
/// and outcomes.
///
/// The queue is scoped to the authenticated user ([currentUserIdProvider]): a
/// user switch rebuilds this against the new owner, so account B never sees or
/// syncs account A's queued entries.

@ProviderFor(AttendanceQueueController)
final attendanceQueueControllerProvider = AttendanceQueueControllerProvider._();

/// Owns the offline attendance queue for the UI.
///
/// Every capture is persisted first, then an immediate sync is attempted
/// ("always enqueue, then sync"). The queue is also flushed automatically
/// whenever connectivity is regained. State is the full list of queued entries
/// owned by the current user, newest first, so the UI can show a pending badge
/// and outcomes.
///
/// The queue is scoped to the authenticated user ([currentUserIdProvider]): a
/// user switch rebuilds this against the new owner, so account B never sees or
/// syncs account A's queued entries.
final class AttendanceQueueControllerProvider
    extends
        $AsyncNotifierProvider<
          AttendanceQueueController,
          List<AttendanceQueueEntry>
        > {
  /// Owns the offline attendance queue for the UI.
  ///
  /// Every capture is persisted first, then an immediate sync is attempted
  /// ("always enqueue, then sync"). The queue is also flushed automatically
  /// whenever connectivity is regained. State is the full list of queued entries
  /// owned by the current user, newest first, so the UI can show a pending badge
  /// and outcomes.
  ///
  /// The queue is scoped to the authenticated user ([currentUserIdProvider]): a
  /// user switch rebuilds this against the new owner, so account B never sees or
  /// syncs account A's queued entries.
  AttendanceQueueControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceQueueControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceQueueControllerHash();

  @$internal
  @override
  AttendanceQueueController create() => AttendanceQueueController();
}

String _$attendanceQueueControllerHash() =>
    r'0b53fbcc6de1c5d46a491942dddea37785bd62d9';

/// Owns the offline attendance queue for the UI.
///
/// Every capture is persisted first, then an immediate sync is attempted
/// ("always enqueue, then sync"). The queue is also flushed automatically
/// whenever connectivity is regained. State is the full list of queued entries
/// owned by the current user, newest first, so the UI can show a pending badge
/// and outcomes.
///
/// The queue is scoped to the authenticated user ([currentUserIdProvider]): a
/// user switch rebuilds this against the new owner, so account B never sees or
/// syncs account A's queued entries.

abstract class _$AttendanceQueueController
    extends $AsyncNotifier<List<AttendanceQueueEntry>> {
  FutureOr<List<AttendanceQueueEntry>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AttendanceQueueEntry>>,
              List<AttendanceQueueEntry>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AttendanceQueueEntry>>,
                List<AttendanceQueueEntry>
              >,
              AsyncValue<List<AttendanceQueueEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The number of entries still awaiting sync.

@ProviderFor(pendingAttendanceCount)
final pendingAttendanceCountProvider = PendingAttendanceCountProvider._();

/// The number of entries still awaiting sync.

final class PendingAttendanceCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// The number of entries still awaiting sync.
  PendingAttendanceCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingAttendanceCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingAttendanceCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return pendingAttendanceCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$pendingAttendanceCountHash() =>
    r'b3b7f255bdfde07be8f87de2dcbf7d48dffb72f2';

/// Today's still-pending check-in / check-out actions, derived from the local
/// queue. Lets the presence screen reflect an offline capture immediately (so a
/// user can't double-queue a check-in, and can queue a check-out afterwards)
/// without waiting for the server-backed dashboard.

@ProviderFor(pendingAttendanceActions)
final pendingAttendanceActionsProvider = PendingAttendanceActionsProvider._();

/// Today's still-pending check-in / check-out actions, derived from the local
/// queue. Lets the presence screen reflect an offline capture immediately (so a
/// user can't double-queue a check-in, and can queue a check-out afterwards)
/// without waiting for the server-backed dashboard.

final class PendingAttendanceActionsProvider
    extends
        $FunctionalProvider<
          PendingAttendanceActions,
          PendingAttendanceActions,
          PendingAttendanceActions
        >
    with $Provider<PendingAttendanceActions> {
  /// Today's still-pending check-in / check-out actions, derived from the local
  /// queue. Lets the presence screen reflect an offline capture immediately (so a
  /// user can't double-queue a check-in, and can queue a check-out afterwards)
  /// without waiting for the server-backed dashboard.
  PendingAttendanceActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingAttendanceActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingAttendanceActionsHash();

  @$internal
  @override
  $ProviderElement<PendingAttendanceActions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PendingAttendanceActions create(Ref ref) {
    return pendingAttendanceActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingAttendanceActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingAttendanceActions>(value),
    );
  }
}

String _$pendingAttendanceActionsHash() =>
    r'125c1e4a40f65b2da78f453b4d6f04259455dc04';
