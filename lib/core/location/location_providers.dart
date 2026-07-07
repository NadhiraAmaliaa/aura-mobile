import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'location_service.dart';

part 'location_providers.g.dart';

/// The device location service seam (real GPS in production, faked in tests).
@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) => const GeolocatorLocationService();
