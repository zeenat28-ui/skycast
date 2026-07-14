import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  try {
    return await Geolocator.checkPermission();
  } catch (_) {
    return LocationPermission.denied;
  }
});
