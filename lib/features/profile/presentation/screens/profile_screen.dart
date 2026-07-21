import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/avatar_notifier.dart';

/// The intern's profile home.
///
/// Presents the profile header (photo + name + NIM), a read-only "Informasi
/// Kontak" section with a single edit affordance in its header, and the profile
/// menu (Informasi Magang, Ganti Password, Logout). The header's camera button
/// lets the intern change or remove their profile photo.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    final user = switch (state) {
      AsyncData(value: Authenticated(:final user)) => user,
      _ => null,
    };

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 24),
          _ContactSection(user: user),
          const SizedBox(height: 24),
          _MenuSection(user: user),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final nim = user.intern?.nim;
    final isBusy = ref.watch(avatarProvider).isLoading;
    final avatarUrl = ref.watch(appEnvProvider).resolveAssetUrl(user.avatarUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _Avatar(
            avatarUrl: avatarUrl,
            isBusy: isBusy,
            onEditPhoto: () => _showPhotoOptions(context, ref),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (nim != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$nim (NIM)',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPhotoOptions(BuildContext context, WidgetRef ref) async {
    if (ref.read(avatarProvider).isLoading) return;

    final hasPhoto = user.avatarUrl != null;
    final choice = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dari kamera'),
              onTap: () => Navigator.of(context).pop(_PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.of(context).pop(_PhotoAction.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Hapus foto',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => Navigator.of(context).pop(_PhotoAction.remove),
              ),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    switch (choice) {
      case _PhotoAction.camera:
        await _pickAndUpload(context, ref, ImageSource.camera);
      case _PhotoAction.gallery:
        await _pickAndUpload(context, ref, ImageSource.gallery);
      case _PhotoAction.remove:
        await _removePhoto(context, ref);
    }
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } on Object {
      if (context.mounted) {
        _showMessage(context, 'Tidak dapat mengakses kamera atau galeri.');
      }
      return;
    }
    if (picked == null) return;

    final result = await ref
        .read(avatarProvider.notifier)
        .upload(File(picked.path));
    if (!context.mounted) return;

    result.fold(
      onSuccess: (_) =>
          _showMessage(context, 'Foto profil berhasil diperbarui.'),
      onFailure: (error) => _showMessage(context, _errorMessage(error)),
    );
  }

  Future<void> _removePhoto(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(avatarProvider.notifier).remove();
    if (!context.mounted) return;

    result.fold(
      onSuccess: (_) => _showMessage(context, 'Foto profil dihapus.'),
      onFailure: (error) => _showMessage(context, _errorMessage(error)),
    );
  }

  String _errorMessage(AppException error) {
    if (error is ValidationException) {
      final photoErrors = error.errors['photo'];
      if (photoErrors != null && photoErrors.isNotEmpty) {
        return photoErrors.first;
      }
    }
    return error.message;
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// The action chosen from the profile-photo bottom sheet.
enum _PhotoAction { camera, gallery, remove }

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatarUrl,
    required this.isBusy,
    required this.onEditPhoto,
  });

  final String? avatarUrl;
  final bool isBusy;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = avatarUrl;

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            backgroundImage: url == null ? null : NetworkImage(url),
            child: url == null ? const Icon(Icons.person, size: 40) : null,
          ),
          if (isBusy)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.scrim.withValues(alpha: 0.45),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: scheme.primary,
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: isBusy ? null : onEditPhoto,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Informasi Kontak',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Ubah kontak',
              onPressed: () => context.pushNamed(RouteNames.profileContact),
              style: IconButton.styleFrom(
                foregroundColor: scheme.primary,
                side: BorderSide(color: scheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ContactCard(
          icon: Icons.mail_outline,
          label: 'Email',
          value: user.email ?? '-',
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.phone_outlined,
          label: 'Nomor HP',
          value: user.intern?.phone ?? '-',
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Icon(icon, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends ConsumerWidget {
  const _MenuSection({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _MenuTile(
          icon: Icons.description_outlined,
          title: 'Informasi Magang',
          onTap: () => context.pushNamed(RouteNames.profileInternship),
        ),
        const SizedBox(height: 12),
        _MenuTile(
          icon: Icons.lock_outline,
          title: 'Ganti Password',
          onTap: () => context.pushNamed(RouteNames.profilePassword),
        ),
        const SizedBox(height: 12),
        _MenuTile(
          icon: Icons.logout,
          title: 'Logout',
          foregroundColor: scheme.error,
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.foregroundColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = foregroundColor ?? scheme.onSurface;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: foregroundColor == null
                    ? scheme.primaryContainer
                    : scheme.errorContainer,
                foregroundColor: foregroundColor == null
                    ? scheme.onPrimaryContainer
                    : scheme.onErrorContainer,
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
