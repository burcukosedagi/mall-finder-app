import 'dart:convert';
import '../../services/api/api_client.dart';
import '../../models/city.dart';
import '../../models/district.dart';

class LocationApi {
  static Future<List<City>> fetchCities() async {
    final response = await ApiClient.get('/cities');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => City.fromJson(e)).toList();
    } else {
      throw Exception('Şehir verileri alınamadı');
    }
  }

  static Future<List<District>> fetchDistricts(int cityId) async {
    final response = await ApiClient.get('/districts?city_id=$cityId');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => District.fromJson(e)).toList();
    } else {
      throw Exception('İlçeler alınamadı');
    }
  }
}
