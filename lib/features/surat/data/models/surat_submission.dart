/// The user's input for a "Surat Izin Pulang Sebelum Waktunya" (early-leave
/// letter), collected by the submit form.
///
/// A plain value object, not a JSON DTO: the repository maps it onto the
/// request body. The intern's identity (name, NIM, program, etc.) is NOT part
/// of this — the backend pulls it from the authenticated account.
///
/// The field set is provisional: it mirrors the current backend contract while
/// SDM confirms the final letter structure. Adjust here (plus the form and the
/// repository's body mapping) when the requirements settle.
class SuratSubmission {
  const SuratSubmission({
    required this.earlyLeaveDate,
    required this.leaveTime,
    required this.reason,
  });

  /// The day the intern will leave early.
  final DateTime earlyLeaveDate;

  /// Time of leaving the office, as `HH:mm` (24-hour), e.g. `14:30`.
  final String leaveTime;

  /// Free-text reason for leaving before working hours end.
  final String reason;
}
