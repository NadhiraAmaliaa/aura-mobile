import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../../../shared/widgets/aura_form.dart';
import '../../data/models/leave_models.dart';
import '../providers/leave_detail_notifier.dart';
import '../providers/leave_download_notifier.dart';
import '../widgets/leave_request_visuals.dart';
import '../widgets/leave_status_chip.dart';

// Zero letter spacing overrides the inherited M3 body tracking, as on Home.
const _labelStyle = TextStyle(
  color: AuraForm.bodyMuted,
  fontSize: 13,
  height: 1.3,
  letterSpacing: 0,
);
const _valueStyle = TextStyle(
  color: AuraForm.heading,
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.35,
  letterSpacing: 0,
);

const _cardGap = 16.0;
const _rowGap = 14.0;

/// The icon tiles of the information rows, after the reference design.
const _tileSize = 44.0;

/// The calendar date the server gave the timestamp [iso], e.g. "10 November
/// 2026" for "2026-11-10T23:30:00+07:00".
///
/// Laravel writes timestamps in the app timezone (Asia/Jakarta) with their
/// offset, so the leading date is the business date the web app and the PDF
/// show. It is used as sent: parsing the timestamp turns it into UTC (the day
/// before for early-morning decisions), and converting to this device's
/// timezone would move it to another day outside WIB. Returns [iso]
/// unchanged when it is not a timestamp that starts with a date, as
/// [formatIndoDate] does.
String _serverDate(String iso) {
  final date = RegExp(r'^\d{4}-\d{2}-\d{2}').stringMatch(iso);
  if (date == null || DateTime.tryParse(iso) == null) return iso;
  return formatIndoDate(date);
}

/// Read-only detail of a single leave request.
///
/// Displays every field returned by the API plus the file actions added in
/// Slice 4: viewing the evidence attachment and printing the approved PDF.
class LeaveDetailScreen extends ConsumerWidget {
  const LeaveDetailScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(leaveDetailProvider(id));

    return AuraPageScaffold(
      title: 'Detail Pengajuan',
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(leaveDetailProvider(id).notifier).refresh(),
          child: switch (detail) {
            AsyncData(:final value) => _DetailBody(request: value),
            AsyncError(:final error) => _ErrorView(
              message: error is AppException
                  ? error.message
                  : 'Gagal memuat detail pengajuan.',
              onRetry: () =>
                  ref.read(leaveDetailProvider(id).notifier).refresh(),
            ),
            _ => const _LoadingView(),
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.request});

  final LeaveRequestModel request;

  @override
  Widget build(BuildContext context) {
    final horizontal = AuraForm.pageInset(MediaQuery.sizeOf(context).width);
    final accent = LeaveTypeAccent.of(request.type);
    final totalDays = request.totalDays;
    final address = request.address;
    final contact = request.contactPhone;

    // The mentor's note: the reason for a rejection, a remark on an approval.
    final note = request.adminNote;
    final noteLabel = note == null || note.isEmpty
        ? null
        : switch (request.status) {
            'rejected' => 'Catatan Penolakan',
            'approved' => 'Catatan Mentor',
            _ => null,
          };

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
      children: [
        LeaveRequestHeading.large(request: request),
        const SizedBox(height: 20),

        _DetailCard(
          children: [
            _DetailRow(
              leading: _DateIcon(Icons.calendar_today_outlined, accent),
              label: 'Tanggal Mulai',
              value: request.startDate != null
                  ? formatIndoDateWithWeekday(request.startDate!)
                  : '-',
            ),
            const SizedBox(height: 16),
            _DetailRow(
              leading: _DateIcon(Icons.event_outlined, accent),
              label: 'Tanggal Selesai',
              value: request.endDate != null
                  ? formatIndoDateWithWeekday(request.endDate!)
                  : '-',
            ),
            // Hidden rather than "null hari" when the count is unknown.
            if (totalDays != null) ...[
              const _RowDivider(),
              _DetailRow(
                leading: _DateIcon(Icons.calendar_month_outlined, accent),
                label: 'Jumlah Hari',
                content: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: LeaveDaysPill(days: totalDays, accent: accent),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: _cardGap),

        _DetailCard(
          children: _separated([
            _DetailRow(
              leading: const _IconTile(
                Icons.sms_outlined,
                tint: Color(0xFFFFF1D6),
                color: Color(0xFFD48A0C),
              ),
              label: 'Alasan',
              value: request.reason,
            ),
            if (address != null && address.isNotEmpty)
              _DetailRow(
                leading: const _IconTile(
                  Icons.location_on_outlined,
                  tint: Color(0xFFE3EEFF),
                  color: Color(0xFF3D72C9),
                ),
                label: 'Alamat',
                value: address,
              ),
            if (contact != null && contact.isNotEmpty)
              _DetailRow(
                leading: const _IconTile(
                  Icons.call_outlined,
                  tint: Color(0xFFE3F4DC),
                  color: Color(0xFF2E7D1E),
                ),
                label: 'Kontak',
                value: contact,
              ),
            if (request.evidenceUrl != null)
              const _DetailRow(
                leading: _IconTile(
                  Icons.attach_file_rounded,
                  tint: Color(0xFFE6E5FB),
                  color: Color(0xFF6A62C9),
                ),
                label: 'Lampiran',
                value: 'Tersedia',
              ),
          ]),
        ),

        if (request.approverName != null ||
            request.approvedAt != null ||
            noteLabel != null) ...[
          const SizedBox(height: _cardGap),
          _ProcessingCard(request: request, noteLabel: noteLabel),
        ],

        if (request.evidenceUrl != null || request.canDownloadPdf) ...[
          const SizedBox(height: 24),
          _DetailActions(request: request),
        ],
      ],
    );
  }
}

/// Who decided the request and when, as plain label-and-value rows, with the
/// mentor's note under [noteLabel] on an inset panel in the status's colours.
class _ProcessingCard extends StatelessWidget {
  const _ProcessingCard({required this.request, required this.noteLabel});

  final LeaveRequestModel request;
  final String? noteLabel;

  @override
  Widget build(BuildContext context) {
    final approver = request.approverName;
    final approvedAt = request.approvedAt;
    // No icons here, so the divider spans the whole row.
    final rows = _separated(indent: 0, [
      if (approver != null) _DetailRow(label: 'Diproses oleh', value: approver),
      if (approvedAt != null)
        _DetailRow(label: 'Tanggal Diproses', value: _serverDate(approvedAt)),
    ]);

    return _DetailCard(
      children: [
        ...rows,
        if (noteLabel != null) ...[
          if (rows.isNotEmpty) const SizedBox(height: 16),
          _NotePanel(
            label: noteLabel!,
            note: request.adminNote!,
            status: request.status,
          ),
        ],
      ],
    );
  }
}

/// The mentor's note on a soft panel of the status's colour.
class _NotePanel extends StatelessWidget {
  const _NotePanel({
    required this.label,
    required this.note,
    required this.status,
  });

  final String label;
  final String note;
  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = leaveStatusColors(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.all(Radius.circular(14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: MergeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                status == 'rejected'
                    ? Icons.info_outline
                    : Icons.chat_bubble_outline,
                size: 20,
                color: colors.foreground,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: _labelStyle.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note,
                      style: const TextStyle(
                        color: AuraForm.heading,
                        fontSize: 14,
                        height: 1.45,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [rows] with a hairline between each pair, starting [indent] in: by
/// default where the text of rows with an icon tile starts.
List<Widget> _separated(
  List<Widget> rows, {
  double indent = _tileSize + _rowGap,
}) => [
  for (final (index, row) in rows.indexed) ...[
    if (index > 0) _RowDivider(indent: indent),
    row,
  ],
];

class _RowDivider extends StatelessWidget {
  const _RowDivider({this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent, top: 14, bottom: 14),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: AuraForm.fieldBorder,
      ),
    );
  }
}

/// A white leave card holding detail rows.
class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LeaveCardSurface(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// A label over its [value] (or [content]), read as one by screen readers,
/// beside [leading] when given. Text shorter than [leading] centres on it;
/// longer text starts level with its top.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.leading,
    this.value,
    this.content,
  }) : assert((value == null) != (content == null));

  final _Leading? leading;
  final String label;
  final String? value;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final text = MergeSemantics(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 3),
          content ?? Text(value!, style: _valueStyle),
        ],
      ),
    );
    final leading = this.leading;
    if (leading == null) return text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        const SizedBox(width: _rowGap),
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: leading.extent),
            child: text,
          ),
        ),
      ],
    );
  }
}

/// The decorative icon at the start of a [_DetailRow], [extent] tall.
abstract class _Leading extends StatelessWidget {
  const _Leading();

  double get extent;
}

/// A date row's icon in the request type's colour, as tall as a row's label
/// and value so it centres on them.
class _DateIcon extends _Leading {
  const _DateIcon(this.icon, this.accent);

  final IconData icon;
  final LeaveTypeAccent accent;

  @override
  double get extent => 22;

  @override
  Widget build(BuildContext context) {
    // Centred on the label and the first line of the value.
    final textScaler = MediaQuery.textScalerOf(context);
    final twoLines =
        textScaler.scale(_labelStyle.fontSize!) * _labelStyle.height! +
        3 +
        textScaler.scale(_valueStyle.fontSize!) * _valueStyle.height!;
    return Padding(
      padding: EdgeInsets.only(top: ((twoLines - extent) / 2).clamp(0, 99)),
      child: Icon(icon, size: extent, color: accent.foreground),
    );
  }
}

/// An information row's icon on a tinted rounded square.
class _IconTile extends _Leading {
  const _IconTile(this.icon, {required this.tint, required this.color});

  final IconData icon;
  final Color tint;
  final Color color;

  @override
  double get extent => _tileSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _tileSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}

/// File actions for a leave request: open the evidence attachment and print
/// the approved-request PDF (native print / "Save as PDF" preview). Both are
/// gated on a shared loading state so only one fetch runs at a time; failures
/// surface via a snackbar.
class _DetailActions extends ConsumerWidget {
  const _DetailActions({required this.request});

  final LeaveRequestModel request;

  // A soft navy companion to the navy Cetak PDF button.
  static const _attachmentFill = Color(0xFFE8EFFB);
  static const _attachmentInk = Color(0xFF0B2559);
  static final _attachmentStyle = FilledButton.styleFrom(
    backgroundColor: _attachmentFill,
    foregroundColor: _attachmentInk,
    disabledBackgroundColor: _attachmentFill.withValues(alpha: 0.6),
    disabledForegroundColor: _attachmentInk.withValues(alpha: 0.45),
    elevation: 0,
    shape: const StadiumBorder(),
    minimumSize: const Size.fromHeight(52),
    iconSize: 20,
  );

  // On the Text, as AuraSubmitButton does: ButtonStyle.textStyle would drop
  // the theme's font family.
  static const _attachmentLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(leaveDownloadProvider).isLoading;
    final notifier = ref.read(leaveDownloadProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (request.evidenceUrl != null)
          FilledButton.icon(
            onPressed: isBusy
                ? null
                : () => _handle(context, notifier.openEvidence(request)),
            style: _attachmentStyle,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text(
              'Lihat Lampiran',
              style: _attachmentLabelStyle,
              textAlign: TextAlign.center,
            ),
          ),
        if (request.evidenceUrl != null && request.canDownloadPdf)
          const SizedBox(height: 12),
        if (request.canDownloadPdf)
          AuraSubmitButton(
            label: 'Cetak PDF',
            icon: Icons.print_outlined,
            onPressed: isBusy
                ? null
                : () => _handle(
                    context,
                    notifier.printPdf(request),
                    preparingMessage: 'Menyiapkan PDF…',
                  ),
          ),
      ],
    );
  }

  Future<void> _handle(
    BuildContext context,
    Future<ApiResult<void>> action, {
    String? preparingMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    // The first PDF render after a cold server start can take a few seconds;
    // show a hint so the disabled button doesn't look frozen during the wait.
    if (preparingMessage != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(preparingMessage),
            duration: const Duration(minutes: 2),
          ),
        );
    }
    final result = await action;
    if (preparingMessage != null) {
      messenger.hideCurrentSnackBar();
    }
    result.fold(
      onSuccess: (_) {},
      onFailure: (error) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 240),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 160),
        Icon(
          Icons.cloud_off_outlined,
          size: 56,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AuraForm.heading,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}
