import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiClient {
  static Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await http.get(uri);
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
}
