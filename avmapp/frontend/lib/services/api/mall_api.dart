import 'dart:convert';
import 'dart:math';
import '../../services/api/api_client.dart';
import '../../models/mall.dart';

class MallApi {
  static Future<List<Mall>> fetchMalls() async {
    final response = await ApiClient.get('/malls');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((e) => Mall.fromJson(e)).toList();
    } else {
      throw Exception('AVM verileri alınamadı');
    }
  }

  static Future<List<Mall>> fetchRandomMalls(int count) async {
    final response = await ApiClient.get('/malls');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final allMalls = (data as List).map((e) => Mall.fromJson(e)).toList();
      allMalls.shuffle(Random());
      return allMalls.take(count).toList();
    } else {
      throw Exception('Rastgele AVM verileri alınamadı');
    }
  }

  static Future<List<Mall>> sortMalls(String by, String order) async {
    final response = await ApiClient.get('/malls?sort_by=$by&order=$order');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((e) => Mall.fromJson(e)).toList();
    } else {
      throw Exception('Sıralama verileri alınamadı');
    }
  }

  static Future<List<Mall>> filterMalls({
    List<int>? brandIds,
    List<int>? facilityIds,
    int? cityId,
    int? districtId,
  }) async {
    final queryParams = <String, String>{};
    if (brandIds?.isNotEmpty ?? false)
      queryParams['brandIds'] = brandIds!.join(',');
    if (facilityIds?.isNotEmpty ?? false)
      queryParams['facilityIds'] = facilityIds!.join(',');
    if (cityId != null) queryParams['cityId'] = cityId.toString();
    if (districtId != null) queryParams['districtId'] = districtId.toString();

    final uri = Uri.parse(
      '/filter-malls',
    ).replace(queryParameters: queryParams);
    final response = await ApiClient.get(uri.toString());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((e) => Mall.fromJson(e)).toList();
    } else {
      throw Exception("Filtrelenmiş AVM verileri alınamadı");
    }
  }

  static Future<Mall> fetchMallById(int id) async {
    final response = await ApiClient.get('/malls/$id');
    if (response.statusCode == 200) {
      return Mall.fromJson(json.decode(response.body));
    } else {
      throw Exception('AVM bilgisi alınamadı');
    }
  }

  static Future<List<String>> fetchMallStores(int mallId) async {
    final response = await ApiClient.get('/malls/$mallId/brands');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => e['name'].toString()).toList();
    } else {
      throw Exception('Mağazalar alınamadı');
    }
  }
}
