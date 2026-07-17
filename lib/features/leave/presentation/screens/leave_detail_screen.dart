import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/utils/indo_date.dart';
import '../../data/models/leave_models.dart';
import '../providers/leave_detail_notifier.dart';
import '../providers/leave_download_notifier.dart';
import '../widgets/leave_status_chip.dart';

/// Read-only detail of a single leave request.
///
/// Displays every field returned by the API plus the file actions added in
/// Slice 4: viewing the evidence attachment and downloading the approved PDF.
class LeaveDetailScreen extends ConsumerWidget {
  const LeaveDetailScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(leaveDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengajuan')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(leaveDetailProvider(id).notifier).refresh(),
        child: switch (detail) {
          AsyncData(:final value) => _DetailBody(request: value),
          AsyncError(:final error) => _ErrorView(
            message: error is AppException
                ? error.message
                : 'Gagal memuat detail pengajuan.',
            onRetry: () => ref.read(leaveDetailProvider(id).notifier).refresh(),
          ),
          _ => const _LoadingView(),
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.request});

  final LeaveRequestModel request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRejected = request.status == 'rejected';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                request.typeLabel,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            LeaveStatusChip(label: request.statusLabel, status: request.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          request.requestNumber,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        _DetailCard(
          children: [
            _DetailRow(
              label: 'Tanggal Mulai',
              value: request.startDate != null
                  ? formatIndoDateWithWeekday(request.startDate!)
                  : '-',
            ),
            _DetailRow(
              label: 'Tanggal Selesai',
              value: request.endDate != null
                  ? formatIndoDateWithWeekday(request.endDate!)
                  : '-',
            ),
            _DetailRow(
              label: 'Jumlah Hari',
              value: '${request.totalDays} hari',
            ),
          ],
        ),
        const SizedBox(height: 16),

        _DetailCard(
          children: [
            _DetailRow(label: 'Alasan', value: request.reason),
            if (request.address != null && request.address!.isNotEmpty)
              _DetailRow(label: 'Alamat', value: request.address!),
            if (request.contactPhone != null &&
                request.contactPhone!.isNotEmpty)
              _DetailRow(label: 'Kontak', value: request.contactPhone!),
            if (request.evidenceUrl != null)
              const _DetailRow(label: 'Lampiran', value: 'Tersedia'),
          ],
        ),

        if (request.approverName != null || request.approvedAt != null) ...[
          const SizedBox(height: 16),
          _DetailCard(
            children: [
              if (request.approverName != null)
                _DetailRow(
                  label: 'Diproses oleh',
                  value: request.approverName!,
                ),
              if (request.approvedAt != null)
                _DetailRow(
                  label: 'Tanggal Diproses',
                  value: formatIndoDate(request.approvedAt!),
                ),
            ],
          ),
        ],

        if (isRejected &&
            request.adminNote != null &&
            request.adminNote!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailCard(
            color: theme.colorScheme.errorContainer,
            children: [
              _DetailRow(
                label: 'Catatan Penolakan',
                value: request.adminNote!,
                valueColor: theme.colorScheme.onErrorContainer,
              ),
            ],
          ),
        ],

        if (request.evidenceUrl != null || request.canDownloadPdf) ...[
          const SizedBox(height: 24),
          _DetailActions(request: request),
        ],
      ],
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(leaveDownloadProvider).isLoading;
    final notifier = ref.read(leaveDownloadProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (request.evidenceUrl != null)
          OutlinedButton.icon(
            onPressed: isBusy
                ? null
                : () => _handle(context, notifier.openEvidence(request)),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Lihat Lampiran'),
          ),
        if (request.evidenceUrl != null && request.canDownloadPdf)
          const SizedBox(height: 12),
        if (request.canDownloadPdf)
          FilledButton.icon(
            onPressed: isBusy
                ? null
                : () => _handle(
                    context,
                    notifier.printPdf(request),
                    preparingMessage: 'Menyiapkan PDF…',
                  ),
            icon: const Icon(Icons.print_outlined),
            label: const Text('Cetak PDF'),
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
    // The approved-PDF render can take tens of seconds on a cold server; show a
    // hint so the disabled button doesn't look frozen during the wait.
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

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children, this.color});

  final List<Widget> children;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color ?? theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: children),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: valueColor ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(color: valueColor),
          ),
        ],
      ),
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
        Text(message, textAlign: TextAlign.center),
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
