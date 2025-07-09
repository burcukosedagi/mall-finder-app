import 'package:frontend/services/api/mall_api.dart';
import '../models/mall.dart';

class SearchController {
  static Future<List<Mall>> fetchMalls() async {
    return await MallApi.fetchMalls();
  }

  static Future<List<Mall>> sortMalls(String by, String order) async {
    return await MallApi.sortMalls(by, order);
  }

  static Future<List<Mall>> filterMalls({
    List<int>? brandIds,
    List<int>? facilityIds,
    int? cityId,
    int? districtId,
  }) async {
    return await MallApi.filterMalls(
      brandIds: brandIds,
      facilityIds: facilityIds,
      cityId: cityId,
      districtId: districtId,
    );
  }

  static List<Mall> searchMalls(List<Mall> malls, String query) {
    final lowerQuery = query.toLowerCase();

    return malls.where((mall) {
      final name = mall.name.toLowerCase();
      final city = mall.city?.toLowerCase() ?? '';
      final district = mall.district?.toLowerCase() ?? '';

      return name.contains(lowerQuery) ||
          city.contains(lowerQuery) ||
          district.contains(lowerQuery);
    }).toList();
  }
}
