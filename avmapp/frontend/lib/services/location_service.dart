
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Konum izinlerini kontrol et ve iste
  static Future<bool> _handleLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Konum servisi kapalı
      return false;
    }

    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.locationWhenInUse.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings(); // Ayarlara yönlendir
      return false;
    }
    return false;
  }

  /// Mevcut konumu getir
  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('❌ Konum alınamadı: $e');
      return null;
    }
  }
}
