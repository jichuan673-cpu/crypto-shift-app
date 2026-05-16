import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class WordPressApi {
  static const String _baseUrl = 'https://crypto-shift.com/wp-json/wp/v2';
  static const String _premiumApiKey = 'CS_PREMIUM_KEY_2026';
  static const String _premiumBaseUrl = 'https://crypto-shift.com/wp-json/cryptoshift/v1';

  static Future<List<Article>> getPosts({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    List<int>? categoryIds,
    String? searchQuery,
  }) async {
    String url = '$_baseUrl/posts?page=$page&per_page=$perPage&_embed=1';

    if (categoryIds != null && categoryIds.isNotEmpty) {
      url += '&categories=${categoryIds.join(',')}';
    } else if (categoryId != null) {
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

  /// プレミアム会員向け：private記事を含むすべての記事を取得
  static Future<List<Article>> getPremiumPosts({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    List<int>? categoryIds,
    String? searchQuery,
  }) async {
    String url = '$_premiumBaseUrl/premium-posts?page=$page&per_page=$perPage';

    if (categoryIds != null && categoryIds.isNotEmpty) {
      url += '&categories=${categoryIds.join(',')}';
    } else if (categoryId != null) {
      url += '&categories=$categoryId';
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(searchQuery)}';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'X-CS-App-Key': _premiumApiKey,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        // フォールバック: 通常エンドポイントで再試行
        return getPosts(
          page: page,
          perPage: perPage,
          categoryId: categoryId,
          categoryIds: categoryIds,
          searchQuery: searchQuery,
        );
      }
    } catch (e) {
      // フォールバック: 通常エンドポイントで再試行
      return getPosts(
        page: page,
        perPage: perPage,
        categoryId: categoryId,
        categoryIds: categoryIds,
        searchQuery: searchQuery,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories?per_page=100'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((c) => {
                  'id': c['id'] as int,
                  'name': c['name'] as String,
                  'parent': c['parent'] as int,
                })
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<String> sendChatMessage(List<Map<String, String>> messages) async {
    const url = 'https://crypto-shift.com/wp-json/cryptoshift/v1/chat';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'messages': messages}),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['reply'] ?? '申し訳ありません、回答を生成できませんでした。';
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('通信エラーが発生しました: $e');
    }
  }
}
