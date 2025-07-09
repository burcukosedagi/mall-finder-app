import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_constants.dart';

class LuckyPickApi {
  static Future<List<String>> fetchSuggestedMalls(List<int> activityIds) async {
    final idsString = activityIds.join(',');
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/malls-by-activities?ids=$idsString',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((e) => e['name'] as String).toList();
    } else {
      throw Exception("Hata kodu: ${response.statusCode}");
    }
  }
}
