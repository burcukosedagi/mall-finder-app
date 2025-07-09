import 'dart:convert';
import '../../services/api/api_client.dart';

class CommentApi {
  static Future<bool> submitComment({
    required String name,
    required String email,
    required String comment,
    required int rating,
    required int mallId,
  }) async {
    final response = await ApiClient.post('/comments', {
      'name': name,
      'email': email,
      'comment': comment,
      'rating': rating,
      'mall_id': mallId,
    });
    return response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> fetchComments(int mallId) async {
    final response = await ApiClient.get('/comments?mallId=$mallId');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Yorumlar alınamadı');
    }
  }
}
