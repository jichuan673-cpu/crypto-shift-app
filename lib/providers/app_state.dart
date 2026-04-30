import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/article.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSizeMultiplier = 1.0;
  List<int> _savedArticleIds = [];
  List<int> _likedArticleIds = [];
  List<int> _readArticleIds = [];
  List<String> _categoryOrder = [];
  
  bool _notificationsEnabled = true;
  String _notificationFrequency = 'realtime'; // 'realtime' or 'daily'
  List<int> _subscribedCategoryIds = [];
  
  // 保存・いいねした記事の詳細データキャッシュ
  Map<String, dynamic> _cachedArticlesData = {};

  bool get isDarkMode => _isDarkMode;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  List<int> get savedArticleIds => _savedArticleIds;
  List<int> get likedArticleIds => _likedArticleIds;
  List<int> get readArticleIds => _readArticleIds;
  List<String> get categoryOrder => _categoryOrder;
  bool get notificationsEnabled => _notificationsEnabled;
  String get notificationFrequency => _notificationFrequency;
  List<int> get subscribedCategoryIds => _subscribedCategoryIds;

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
    _categoryOrder = prefs.getStringList('categoryOrder') ?? [];
    
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _notificationFrequency = prefs.getString('notificationFrequency') ?? 'realtime';
    _subscribedCategoryIds = (prefs.getStringList('subscribedCategoryIds') ?? []).map(int.parse).toList();
    
    // アプリ起動時にFCMトピックを同期
    _syncFcmTopics();
    
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
    await prefs.setStringList('categoryOrder', _categoryOrder);
    
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('notificationFrequency', _notificationFrequency);
    await prefs.setStringList('subscribedCategoryIds', _subscribedCategoryIds.map((id) => id.toString()).toList());

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

  Future<void> updateCategoryOrder(List<String> newOrder) async {
    _categoryOrder = newOrder;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categoryOrder', _categoryOrder);
    notifyListeners();
  }

  // --- FCM Notification Logic ---
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    await _syncFcmTopics();
    notifyListeners();
  }

  Future<void> setNotificationFrequency(String frequency) async {
    _notificationFrequency = frequency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationFrequency', frequency);
    await _syncFcmTopics();
    notifyListeners();
  }

  Future<void> toggleSubscribedCategory(int categoryId) async {
    if (_subscribedCategoryIds.contains(categoryId)) {
      _subscribedCategoryIds.remove(categoryId);
    } else {
      _subscribedCategoryIds.add(categoryId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('subscribedCategoryIds', _subscribedCategoryIds.map((id) => id.toString()).toList());
    await _syncFcmTopics();
    notifyListeners();
  }
  
  Future<void> _syncFcmTopics() async {
    final messaging = FirebaseMessaging.instance;
    
    // まず古い可能性のあるものをすべて解除する前提の運用か、
    // ここではシンプルに現在の設定に基づいて登録・解除を行う
    if (!_notificationsEnabled) {
      // 全てオフにする場合は主なトピックを解除
      await messaging.unsubscribeFromTopic('all_articles_realtime');
      await messaging.unsubscribeFromTopic('all_articles_daily');
      for (final id in _subscribedCategoryIds) {
        await messaging.unsubscribeFromTopic('category_${id}_realtime');
        await messaging.unsubscribeFromTopic('category_${id}_daily');
      }
      return;
    }

    final isDaily = _notificationFrequency == 'daily';
    
    // 全体通知 (カテゴリが1つも選択されていない場合は「すべて」とみなす、もしくは「すべて」購読用のフラグが必要)
    // ここでは、カテゴリ指定がない場合は全体のトピックを購読する仕様にします
    if (_subscribedCategoryIds.isEmpty) {
      if (isDaily) {
        await messaging.subscribeToTopic('all_articles_daily');
        await messaging.unsubscribeFromTopic('all_articles_realtime');
      } else {
        await messaging.subscribeToTopic('all_articles_realtime');
        await messaging.unsubscribeFromTopic('all_articles_daily');
      }
    } else {
      // カテゴリ指定がある場合は「すべて」トピックを解除
      await messaging.unsubscribeFromTopic('all_articles_realtime');
      await messaging.unsubscribeFromTopic('all_articles_daily');
      
      // 各カテゴリごとに設定
      for (final id in _subscribedCategoryIds) {
        if (isDaily) {
          await messaging.subscribeToTopic('category_${id}_daily');
          await messaging.unsubscribeFromTopic('category_${id}_realtime');
        } else {
          await messaging.subscribeToTopic('category_${id}_realtime');
          await messaging.unsubscribeFromTopic('category_${id}_daily');
        }
      }
    }
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
