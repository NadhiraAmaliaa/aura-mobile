import 'dart:io';

/// The user's input for a new leave request, collected by the submit form.
///
/// This is a plain value object (not a JSON DTO): the repository maps it onto
/// the multipart request. [type] is `izin` or `sakit`; [evidence] is a local
/// file selected by the user (required for `sakit`, optional for `izin` — the
/// backend form request is the final authority).
class LeaveSubmission {
  const LeaveSubmission({
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.contactPhone,
    this.address,
    this.evidence,
  });

  final String type;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String? contactPhone;
  final String? address;
  final File? evidence;
}
