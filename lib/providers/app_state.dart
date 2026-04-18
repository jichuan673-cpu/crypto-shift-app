import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/article.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSizeMultiplier = 1.0;
  List<int> _savedArticleIds = [];
  List<int> _likedArticleIds = [];
  List<int> _readArticleIds = [];
  
  // 保存・いいねした記事の詳細データキャッシュ
  Map<String, dynamic> _cachedArticlesData = {};

  bool get isDarkMode => _isDarkMode;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  List<int> get savedArticleIds => _savedArticleIds;
  List<int> get likedArticleIds => _likedArticleIds;
  List<int> get readArticleIds => _readArticleIds;

  AppState() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontSizeMultiplier = prefs.getDouble('fontSizeMultiplier') ?? 1.0;
    
    _savedArticleIds = (prefs.getStringList('savedArticleIds') ?? []).map(int.parse).toList();
    _likedArticleIds = (prefs.getStringList('likedArticleIds') ?? []).map(int.parse).toList();
    _readArticleIds = (prefs.getStringList('readArticleIds') ?? []).map(int.parse).toList();
    
    final cachedDataStr = prefs.getString('cachedArticlesData');
    if (cachedDataStr != null) {
      try {
        _cachedArticlesData = jsonDecode(cachedDataStr);
      } catch (e) {
        _cachedArticlesData = {};
      }
    }
    notifyListeners();
  }

  Future<void> _saveState(SharedPreferences prefs) async {
    await prefs.setStringList('savedArticleIds', _savedArticleIds.map((id) => id.toString()).toList());
    await prefs.setStringList('likedArticleIds', _likedArticleIds.map((id) => id.toString()).toList());
    await prefs.setStringList('readArticleIds', _readArticleIds.map((id) => id.toString()).toList());
    await prefs.setString('cachedArticlesData', jsonEncode(_cachedArticlesData));
    await prefs.setDouble('fontSizeMultiplier', _fontSizeMultiplier);
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> changeFontSize(double multiplier) async {
    _fontSizeMultiplier = multiplier;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeMultiplier', multiplier);
    notifyListeners();
  }

  Future<void> toggleSave(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    if (_savedArticleIds.contains(article.id)) {
      _savedArticleIds.remove(article.id);
      _cleanUpCache(article.id);
    } else {
      _savedArticleIds.add(article.id);
      _cachedArticlesData[article.id.toString()] = article.toJson();
    }
    await _saveState(prefs);
    notifyListeners();
  }

  Future<void> toggleLike(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    if (_likedArticleIds.contains(article.id)) {
      _likedArticleIds.remove(article.id);
      _cleanUpCache(article.id);
    } else {
      _likedArticleIds.add(article.id);
      _cachedArticlesData[article.id.toString()] = article.toJson();
    }
    await _saveState(prefs);
    notifyListeners();
  }

  Future<void> markAsRead(Article article) async {
    if (!_readArticleIds.contains(article.id)) {
      final prefs = await SharedPreferences.getInstance();
      _readArticleIds.add(article.id);
      _cachedArticlesData[article.id.toString()] = article.toJson();
      // 履歴は直近100件までに制限
      if (_readArticleIds.length > 100) {
        final removedId = _readArticleIds.removeAt(0);
        _cleanUpCache(removedId);
      }
      await _saveState(prefs);
      notifyListeners();
    }
  }

  void _cleanUpCache(int id) {
    if (!_savedArticleIds.contains(id) && 
        !_likedArticleIds.contains(id) && 
        !_readArticleIds.contains(id)) {
      _cachedArticlesData.remove(id.toString());
    }
  }

  bool isSaved(int id) => _savedArticleIds.contains(id);
  bool isLiked(int id) => _likedArticleIds.contains(id);
  bool isRead(int id) => _readArticleIds.contains(id);

  List<Article> getSavedArticles() {
    return _savedArticleIds
        .where((id) => _cachedArticlesData.containsKey(id.toString()))
        .map((id) => Article.fromJsonLocal(_cachedArticlesData[id.toString()]))
        .toList().reversed.toList();
  }

  List<Article> getLikedArticles() {
    return _likedArticleIds
        .where((id) => _cachedArticlesData.containsKey(id.toString()))
        .map((id) => Article.fromJsonLocal(_cachedArticlesData[id.toString()]))
        .toList().reversed.toList();
  }

  List<Article> getReadArticles() {
    return _readArticleIds
        .where((id) => _cachedArticlesData.containsKey(id.toString()))
        .map((id) => Article.fromJsonLocal(_cachedArticlesData[id.toString()]))
        .toList().reversed.toList();
  }
}
