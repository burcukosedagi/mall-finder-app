import 'package:frontend/models/mall.dart';
import 'package:frontend/services/api/mall_api.dart';

class MallController {
  /// Tüm AVM verilerini API'den çeker
  static Future<List<Mall>> fetchMalls() async {
    return await MallApi.fetchMalls();
  }

  /// İsim üzerinden basit arama filtrelemesi yapar
  static List<Mall> filterMalls(List<Mall> malls, String query) {
    return malls
        .where((mall) => mall.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
