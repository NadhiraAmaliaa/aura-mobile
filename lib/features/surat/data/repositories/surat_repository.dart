import '../../../../core/network/api_result.dart';
import '../models/surat_submission.dart';

/// Boundary for the "Surat Pulang Cepat" letter, consumed by the presentation
/// layer.
///
/// The feature is stateless: there is no list, detail, history, or persistence
/// — only an on-demand document generated from the user's input. The abstract
/// interface is kept solely as a testing seam so the notifier can be exercised
/// against a fake.
abstract interface class SuratRepository {
  /// Sends the letter fields to the backend, which renders the PDF and streams
  /// it back; the platform print / "Save as PDF" preview is then shown so the
  /// user prints or saves it through the system UI. Nothing is persisted.
  Future<ApiResult<void>> generateLetter(SuratSubmission submission);
}
