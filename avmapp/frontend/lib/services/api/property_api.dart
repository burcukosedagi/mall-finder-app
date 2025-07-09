import 'dart:convert';
import 'package:frontend/services/api/api_client.dart';

import '../../models/brand.dart';
import '../../models/facility.dart';

class PropertyApi {
  static Future<List<Brand>> fetchBrands() async {
    final response = await ApiClient.get('/brands');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => Brand.fromJson(e)).toList();
    } else {
      throw Exception('Markalar alınamadı');
    }
  }

  static Future<List<Facility>> fetchFacilities() async {
    final response = await ApiClient.get('/facilities');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => Facility.fromJson(e)).toList();
    } else {
      throw Exception('Olanaklar alınamadı');
    }
  }
}
