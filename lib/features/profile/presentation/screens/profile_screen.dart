import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/widgets/aura_form.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/avatar_notifier.dart';

/// The AURA navy of the app bar, the name and the section titles.
const _navy = Color(0xFF0B2559);

/// The small accent bar before each section title.
const _gold = Color(0xFFF2C94C);
const _pastelBlue = Color(0xFFE3EEFF);
const _pastelBlueBorder = Color(0xFFD3E2F8);

// The white card surface of the other redesigned AURA pages.
const _cardRadius = 20.0;
const _cardShadow = BoxShadow(
  color: Color(0x100E3555),
  blurRadius: 12,
  offset: Offset(0, 5),
);

/// The icon tiles of the contact and menu rows.
const _tileSize = 48.0;
const _tileGap = 16.0;
const _rowInset = 16.0;

/// Between the profile card and the sections that follow it.
const _sectionGap = 20.0;

/// Between a section's title row, 48dp tall for its edit button's tap
/// target, and its card.
const _titleGap = 6.0;

// Zero letter spacing overrides the inherited M3 body tracking, as on Home.
const _sectionTitleStyle = TextStyle(
  color: _navy,
  fontSize: 18,
  fontWeight: FontWeight.w700,
  height: 1.25,
  letterSpacing: 0,
);
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

/// The intern's profile home.
///
/// Presents the profile card (photo + name + NIM), a read-only "Informasi
/// Kontak" section with a single edit affordance in its header, and the profile
/// menu (Informasi Magang, Ganti Password, Logout). The card's camera button
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
    final horizontal = AuraForm.pageInset(MediaQuery.sizeOf(context).width);

    return AuraPageScaffold(
      title: 'Profil',
      foregroundColor: _navy,
      centerTitle: true,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 28),
                children: [
                  _ProfileHeader(user: user),
                  const SizedBox(height: _sectionGap),
                  _ContactSection(user: user),
                  const SizedBox(height: _sectionGap),
                  _MenuSection(user: user),
                ],
              ),
            ),
    );
  }
}

/// A white, rounded, softly shadowed card. Its surface clips [child], so ink
/// splashes and the profile card's waves follow the rounded corners.
class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  static final _borderRadius = BorderRadius.circular(_cardRadius);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        boxShadow: const [_cardShadow],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: _borderRadius,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

/// The profile card: the photo with its camera button, the name and the NIM
/// pill, over soft waves in the bottom-right corner.
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  static const _avatarGap = 18.0;
  static const _nameStyle = TextStyle(
    color: _navy,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );
  static const _pillPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 6);
  static const _pillStyle = TextStyle(
    color: _navy,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nim = user.intern?.nim;
    final isBusy = ref.watch(avatarProvider).isLoading;
    final avatarUrl = ref.watch(appEnvProvider).resolveAssetUrl(user.avatarUrl);
    final avatar = _Avatar(
      avatarUrl: avatarUrl,
      isBusy: isBusy,
      onEditPhoto: () => _showPhotoOptions(context, ref),
    );

    return _WhiteCard(
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _CardWavePainter()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final identity = _identity(nim);
                // Beside the photo, as in the reference, while the NIM pill
                // and every word of the name fit there; under it otherwise.
                final besideWidth =
                    constraints.maxWidth - _Avatar.size - _avatarGap;
                if (besideWidth >= _identityWidth(context, nim)) {
                  return Row(
                    children: [
                      avatar,
                      const SizedBox(width: _avatarGap),
                      Expanded(child: identity),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [avatar, const SizedBox(height: 16), identity],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _identity(String? nim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(user.name, style: _nameStyle),
        if (nim != null) ...[
          const SizedBox(height: 10),
          DecoratedBox(
            // A pill on one line; a rounded box if large text wraps it.
            decoration: const BoxDecoration(
              color: _pastelBlue,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: _pillPadding,
              child: Text('$nim (NIM)', style: _pillStyle),
            ),
          ),
        ],
      ],
    );
  }

  /// The narrowest width that keeps the NIM pill on one line and no word of
  /// the name broken.
  double _identityWidth(BuildContext context, String? nim) {
    final widestWord = user.name
        .split(RegExp(r'\s+'))
        .map((word) => AuraForm.textSize(context, word, _nameStyle).width)
        .fold(0.0, math.max);
    final pill = nim == null
        ? 0.0
        : AuraForm.textSize(context, '$nim (NIM)', _pillStyle).width +
              _pillPadding.horizontal;
    return math.max(widestWord, pill);
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

/// The round photo inside a soft green ring, with the navy camera button on
/// its lower right.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatarUrl,
    required this.isBusy,
    required this.onEditPhoto,
  });

  final String? avatarUrl;
  final bool isBusy;
  final VoidCallback onEditPhoto;

  static const size = 88.0;
  static const _ring = Color(0xFFB9E0AB);
  static const _ringWidth = 3.0;
  static const _ringGap = 3.0;
  static const _placeholder = Color(0xFF5E7787);

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    const inset = _ringWidth + _ringGap;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _ring, width: _ringWidth),
              ),
              child: Padding(
                padding: const EdgeInsets.all(_ringGap),
                child: CircleAvatar(
                  radius: size / 2 - inset,
                  backgroundColor: _pastelBlue,
                  foregroundColor: _placeholder,
                  backgroundImage: url == null ? null : NetworkImage(url),
                  child: url == null
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
              ),
            ),
          ),
          if (isBusy)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(inset),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _navy.withValues(alpha: 0.45),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: -4,
            bottom: -2,
            child: Semantics(
              container: true,
              button: true,
              label: 'Ubah foto profil',
              child: Material(
                color: _navy,
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 2.5),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isBusy ? null : onEditPhoto,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.photo_camera,
                      size: 18,
                      color: Colors.white,
                    ),
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

/// Soft pastel waves rising into the profile card's bottom-right corner, as
/// in the reference: a gold crest just above a green swell. Kept to a fixed
/// band along the bottom, behind the content, however tall the card grows.
class _CardWavePainter extends CustomPainter {
  const _CardWavePainter();

  static const _band = 58.0;
  static const _gold = Color(0xFFF8E3A3);
  static const _greenLight = Color(0xFFD3EDC8);
  static const _green = Color(0xFFB2DCA2);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final bottom = size.height;
    final top = bottom - _band;

    final gold = Path()
      ..moveTo(width * 0.6, bottom)
      ..cubicTo(
        width * 0.78,
        bottom - _band * 0.1,
        width * 0.86,
        top + _band * 0.05,
        width,
        top - _band * 0.08,
      )
      ..lineTo(width, bottom)
      ..close();
    final green = Path()
      ..moveTo(width * 0.42, bottom)
      ..cubicTo(
        width * 0.64,
        bottom - _band * 0.04,
        width * 0.76,
        top + _band * 0.42,
        width,
        top + _band * 0.24,
      )
      ..lineTo(width, bottom)
      ..close();
    final rect = Rect.fromLTRB(width * 0.42, top, width, bottom);

    canvas
      ..drawPath(gold, Paint()..color = _gold.withValues(alpha: 0.85))
      ..drawPath(
        green,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_greenLight, _green],
          ).createShader(rect),
      );
  }

  @override
  bool shouldRepaint(_CardWavePainter oldDelegate) => false;
}

/// A section title after a small gold bar, with an optional [action] on the
/// right.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: const BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: _sectionTitleStyle)),
        if (action != null) ...[const SizedBox(width: 12), action!],
      ],
    );
  }
}

/// A row's icon on its tinted rounded square.
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.tint,
    required this.color,
  });

  final IconData icon;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _tileSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: Icon(icon, size: 24, color: color),
      ),
    );
  }
}

/// Hairline between two rows, starting where their text starts.
class _RowDivider extends StatelessWidget {
  const _RowDivider({this.end = 0});

  final double end;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: _rowInset + _tileSize + _tileGap,
        end: end,
      ),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: AuraForm.fieldBorder,
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Informasi Kontak',
          action: IconButton(
            tooltip: 'Ubah kontak',
            onPressed: () => context.pushNamed(RouteNames.profileContact),
            style: IconButton.styleFrom(
              backgroundColor: _pastelBlue,
              foregroundColor: _navy,
              fixedSize: const Size.square(44),
              side: const BorderSide(color: _pastelBlueBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 22),
          ),
        ),
        const SizedBox(height: _titleGap),
        _WhiteCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                _ContactRow(
                  icon: Icons.mail_outline,
                  tint: _pastelBlue,
                  color: const Color(0xFF3D72C9),
                  label: 'Email',
                  value: user.email ?? '-',
                  // Wraps after the "@" before breaking inside a word.
                  breakAfterAt: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: _RowDivider(end: _rowInset),
                ),
                _ContactRow(
                  icon: Icons.call_outlined,
                  tint: const Color(0xFFE3F4DC),
                  color: const Color(0xFF2E7D1E),
                  label: 'Nomor HP',
                  value: user.intern?.phone ?? '-',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A contact's icon tile beside its label and value, read as one by screen
/// readers.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.tint,
    required this.color,
    required this.label,
    required this.value,
    this.breakAfterAt = false,
  });

  final IconData icon;
  final Color tint;
  final Color color;
  final String label;
  final String value;

  /// Whether a long [value] may wrap after its "@", as an address too wide
  /// for one line would otherwise break mid-word. Display only: screen
  /// readers still get [value] as is.
  final bool breakAfterAt;

  @override
  Widget build(BuildContext context) {
    final shown = breakAfterAt ? value.replaceFirst('@', '@​') : value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _rowInset),
      child: Row(
        children: [
          _IconTile(icon: icon, tint: tint, color: color),
          const SizedBox(width: _tileGap),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: _labelStyle),
                  const SizedBox(height: 3),
                  Text(shown, style: _valueStyle, semanticsLabel: value),
                ],
              ),
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

  static const _logoutRed = Color(0xFFC62F3B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // As tall as the contact title, whose edit button's 48dp tap target
        // makes it taller, so both sections sit the same distance from their
        // cards.
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: const _SectionHeader(title: 'Menu'),
        ),
        const SizedBox(height: _titleGap),
        _WhiteCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.description_outlined,
                  tint: _pastelBlue,
                  iconColor: const Color(0xFF3D72C9),
                  title: 'Informasi Magang',
                  onTap: () => context.pushNamed(RouteNames.profileInternship),
                ),
                const _RowDivider(end: _rowInset),
                _MenuTile(
                  icon: Icons.lock_outline,
                  tint: const Color(0xFFFFF1D6),
                  iconColor: const Color(0xFFD48A0C),
                  title: 'Ganti Password',
                  onTap: () => context.pushNamed(RouteNames.profilePassword),
                ),
                const _RowDivider(end: _rowInset),
                _MenuTile(
                  icon: Icons.logout,
                  tint: const Color(0xFFFDE3E3),
                  iconColor: _logoutRed,
                  title: 'Logout',
                  titleColor: _logoutRed,
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),
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

/// One menu entry: its icon tile, title and a chevron, tappable across the
/// card's full width.
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor = AuraForm.heading,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _rowInset,
          vertical: 12,
        ),
        child: Row(
          children: [
            _IconTile(icon: icon, tint: tint, color: iconColor),
            const SizedBox(width: _tileGap),
            Expanded(
              child: Text(
                title,
                style: _valueStyle.copyWith(color: titleColor),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AuraForm.bodyMuted),
          ],
        ),
      ),
    );
  }
}
