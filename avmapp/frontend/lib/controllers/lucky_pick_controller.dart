import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mall.dart';

class LuckyPickController {
  static Future<List<Mall>> getMallSuggestion(
    List<int> activityIds, {
    required int cityId,
    int? districtId,
  }) async {
    final queryParams = {
      'ids': activityIds.join(','),
      'city_id': cityId.toString(),
      if (districtId != null) 'district_id': districtId.toString(),
    };

    // final uri = Uri.http('localhost:3000', '/malls-by-activities', queryParams);
    final uri = Uri.http(
      '10.0.2.2:3000',
      '/malls-by-activities',
      queryParams,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Mall.fromJson(json)).toList();
    } else {
      throw Exception('AVM önerisi alınamadı: ${response.statusCode}');
    }
  }
}
