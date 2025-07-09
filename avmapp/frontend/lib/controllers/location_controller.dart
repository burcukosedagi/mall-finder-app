import 'package:frontend/services/api/mall_api.dart';
import 'package:geolocator/geolocator.dart';
import '../models/mall.dart';

class NearbyController {
  /// Belirli mesafe içindeki AVM'leri getir (örn. 10 km)
  static Future<List<Mall>> fetchNearbyMalls(
    Position userPosition, {
    double maxDistanceInKm = 10,
  }) async {
    final allMalls = await MallApi.fetchMalls();

    return allMalls.where((mall) {
      if (mall.latitude == null || mall.longitude == null) return false;

      double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        mall.latitude!,
        mall.longitude!,
      );
      return distance <=
          (maxDistanceInKm * 1000); // metre cinsinden karşılaştır
    }).toList();
  }
}
