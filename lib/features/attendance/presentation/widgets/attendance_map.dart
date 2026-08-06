import 'dart:async';

import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/location/location_result.dart';
import '../../data/models/attendance_models.dart';
import '../providers/attendance_locations_provider.dart';

/// Custom map marker asset paths (declared under `assets/markers/` in pubspec).
abstract final class AttendanceMarkerAssets {
  /// Green person pin — the intern's current position.
  static const String user = 'assets/markers/user_marker.png';

  /// Red building pin — an office location.
  static const String office = 'assets/markers/office_marker.png';
}

/// Interactive map for the WFO check-in flow.
///
/// Plots the intern's current position (green pin) alongside every active
/// office (red pin) with a translucent circle for each geofence radius, then
/// frames the camera to fit them all. Office data comes from
/// [attendanceLocationsProvider], so the widget scales to any number of
/// configured offices. It is purely a visualization — the server remains
/// authoritative for the geofence verdict.
class CheckInMap extends ConsumerStatefulWidget {
  const CheckInMap({required this.userPosition, super.key});

  /// The intern's resolved position, or `null` while it is being acquired.
  final GeoPosition? userPosition;

  @override
  ConsumerState<CheckInMap> createState() => _CheckInMapState();
}

class _CheckInMapState extends ConsumerState<CheckInMap> {
  static const double _defaultZoom = 18.5;

  final Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor? _userIcon;
  BitmapDescriptor? _officeIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
  }

  @override
  void didUpdateWidget(covariant CheckInMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-centre once the user position arrives (or changes).
    if (widget.userPosition != oldWidget.userPosition) {
      _recenterOnUser();
    }
  }

  Future<void> _loadMarkerIcons() async {
    final results = await Future.wait([
      _bitmapFromAsset(AttendanceMarkerAssets.user, BitmapDescriptor.hueGreen),
      _bitmapFromAsset(AttendanceMarkerAssets.office, BitmapDescriptor.hueRed),
    ]);
    if (!mounted) return;
    setState(() {
      _userIcon = results[0];
      _officeIcon = results[1];
    });
  }

  /// Builds a marker bitmap from [assetPath].
  ///
  /// The bytes are read in Dart so a missing asset is caught here and falls
  /// back to a coloured default pin. Passing an asset path straight to the
  /// native map (via `BitmapDescriptor.asset`) crashes the app fatally when the
  /// file is absent, because the native side opens the asset lazily.
  Future<BitmapDescriptor> _bitmapFromAsset(
    String assetPath,
    double fallbackHue,
  ) async {
    try {
      final data = await rootBundle.load(assetPath);
      return BitmapDescriptor.bytes(data.buffer.asUint8List(), width: 48);
    } on Object {
      return BitmapDescriptor.defaultMarkerWithHue(fallbackHue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationsAsync = ref.watch(attendanceLocationsProvider);

    // Fills whatever bounded box the parent provides. The Check In screen pins
    // it as a fixed top section, so it never competes with the page scroll.
    return locationsAsync.when(
      loading: () => const _MapMessage(child: CircularProgressIndicator()),
      error: (_, _) => _MapMessage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gagal memuat peta lokasi kantor.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(attendanceLocationsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
      data: _buildMap,
    );
  }

  Widget _buildMap(List<AttendanceLocationModel> offices) {
    final theme = Theme.of(context);
    final userPosition = widget.userPosition;

    final markers = <Marker>{
      if (userPosition != null)
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(userPosition.latitude, userPosition.longitude),
          icon:
              _userIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
        ),
      for (final office in offices)
        Marker(
          markerId: MarkerId('office-${office.id}'),
          position: LatLng(office.latitude, office.longitude),
          icon:
              _officeIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: 'Radius ${office.radius} m',
          ),
        ),
    };

    final circles = <Circle>{
      for (final office in offices)
        Circle(
          circleId: CircleId('radius-${office.id}'),
          center: LatLng(office.latitude, office.longitude),
          radius: office.radius.toDouble(),
          fillColor: theme.colorScheme.error.withValues(alpha: 0.15),
          strokeColor: theme.colorScheme.error,
          strokeWidth: 3,
        ),
    };

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialTarget(offices),
            zoom: _defaultZoom,
          ),
          markers: markers,
          circles: circles,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onMapCreated: (controller) {
            if (!_controller.isCompleted) _controller.complete(controller);
            _recenterOnUser();
          },
        ),
        if (userPosition != null)
          Positioned(
            right: 12,
            bottom: 12,
            child: _MyLocationButton(onPressed: _recenterOnUser),
          ),
      ],
    );
  }

  LatLng _initialTarget(List<AttendanceLocationModel> offices) {
    final userPosition = widget.userPosition;
    if (userPosition != null) {
      return LatLng(userPosition.latitude, userPosition.longitude);
    }
    if (offices.isNotEmpty) {
      return LatLng(offices.first.latitude, offices.first.longitude);
    }
    // Fallback: geographic centre of Indonesia until data resolves.
    return const LatLng(-2.5, 118);
  }

  /// Centres the camera on the intern's current position.
  Future<void> _recenterOnUser() async {
    final userPosition = widget.userPosition;
    if (userPosition == null || !_controller.isCompleted) return;
    final controller = await _controller.future;
    // The widget could have been disposed between the await and here (rapid
    // navigation, parent rebuild), and the native map view may already be torn
    // down. Guard with mounted and catch the PlatformException the native side
    // throws when the view is gone.
    if (!mounted) return;
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(userPosition.latitude, userPosition.longitude),
          _defaultZoom,
        ),
      );
    } on PlatformException {
      // Native map view was disposed — nothing to animate.
    }
  }
}

class _MyLocationButton extends StatelessWidget {
  const _MyLocationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'Lokasi Saya',
      child: Material(
        color: theme.colorScheme.surface,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.my_location,
              size: 22,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
