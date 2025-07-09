import 'package:frontend/services/api/comment_api.dart';

class MallCommentsController {
  static Future<List<Map<String, dynamic>>> fetchAndSortComments(
    int mallId,
    String sortKey,
  ) async {
    final fetched = await CommentApi.fetchComments(mallId);
    return sortComments(fetched, sortKey);
  }

  static List<Map<String, dynamic>> sortComments(
    List<Map<String, dynamic>> comments,
    String key,
  ) {
    if (key == 'newest') {
      comments.sort((a, b) => b['created_at'].compareTo(a['created_at']));
    } else if (key == 'oldest') {
      comments.sort((a, b) => a['created_at'].compareTo(b['created_at']));
    } else if (key == 'highest') {
      comments.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    } else if (key == 'lowest') {
      comments.sort((a, b) => (a['rating'] ?? 0).compareTo(b['rating'] ?? 0));
    }
    return comments;
  }

  static List<Map<String, dynamic>> filterComments({
    required List<Map<String, dynamic>> comments,
    String? query,
    String? ratingFilter,
  }) {
    List<Map<String, dynamic>> result = comments;

    if (ratingFilter == '4+') {
      result = result.where((c) => (c['rating'] ?? 0) >= 4).toList();
    } else if (ratingFilter == '1-2') {
      result =
          result.where((c) {
            final rating = c['rating'] ?? 0;
            return rating == 1 || rating == 2;
          }).toList();
    }

    if (query != null && query.isNotEmpty) {
      result =
          result.where((c) {
            final name = (c['name'] ?? '').toString().toLowerCase();
            final content = (c['comment'] ?? '').toString().toLowerCase();
            return name.contains(query.toLowerCase()) ||
                content.contains(query.toLowerCase());
          }).toList();
    }

    return result;
  }
}
