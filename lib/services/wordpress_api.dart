import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class WordPressApi {
  static const String _baseUrl = 'https://crypto-shift.com/wp-json/wp/v2';

  static Future<List<Article>> getPosts({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? searchQuery,
  }) async {
    String url = '$_baseUrl/posts?page=$page&per_page=$perPage&_embed=1';

    if (categoryId != null) {
      url += '&categories=$categoryId';
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(searchQuery)}';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('記事の取得に失敗しました: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories?per_page=20'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((c) => {'id': c['id'], 'name': c['name'] as String})
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
