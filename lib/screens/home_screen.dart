import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:marquee/marquee.dart';
import '../models/article.dart';
import '../services/wordpress_api.dart';
import '../services/market_data_api.dart';
import '../providers/app_state.dart';
import 'article_detail_screen.dart';
import 'premium_paywall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSearching = false;
  String _searchQuery = '';
  TabController? _tabController;

  late final MarketDataApi _marketDataApi;

  @override
  void initState() {
    super.initState();
    _marketDataApi = MarketDataApi()..connect();
    _loadCategories();
  }

  // デフォルトのカテゴリ表示順（新規インストール時）
  static const _defaultCategoryOrder = [
    '仮想通貨',
    '不動産',
    'エネルギー資源',
    '政治/経済',
    'ウィークリーレポート',
    '企業分析',
    '特集',
  ];

  Future<void> _loadCategories() async {
    final savedOrder = context.read<AppState>().categoryOrder;
    final cats = await WordPressApi.getCategories();

    // 保存済み順があればそれを使用、なければデフォルト順を適用
    final order = savedOrder.isNotEmpty ? savedOrder : _defaultCategoryOrder;
    cats.sort((a, b) {
      final aIndex = order.indexOf(a['name'] as String);
      final bIndex = order.indexOf(b['name'] as String);
      if (aIndex == -1 && bIndex == -1) return 0;
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });

    if (mounted) {
      final filtered = cats.where((c) => (c['name'] as String).toLowerCase() != 'premium').toList();
      final newController = TabController(
        length: filtered.length + 1, // +1 for 'すべて'
        vsync: this,
      );
      _tabController?.dispose();
      setState(() {
        _categories = filtered;
        _tabController = newController;
        _isLoadingCategories = false;
      });
    }
  }

  int? _getCategoryId(String name) {
    try {
      return _categories.firstWhere((c) => c['name'] == name)['id'] as int?;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    _marketDataApi.dispose();
    super.dispose();
  }

  void _showCategoryReorderSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 現在の順番をコピーして編集用に使う
    final editableCategories = List<Map<String, dynamic>>.from(_categories);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // ハンドルバー
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Text('カテゴリの並び替え',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            )),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // 並び順を保存して閉じる
                            setState(() {
                              _categories = editableCategories;
                            });
                            final newController = TabController(
                              length: _categories.length + 1,
                              vsync: this,
                            );
                            _tabController?.dispose();
                            setState(() => _tabController = newController);
                            context.read<AppState>().updateCategoryOrder(
                                _categories.map((c) => c['name'] as String).toList());
                            Navigator.pop(context);
                          },
                          child: const Text('完了',
                              style: TextStyle(
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('ドラッグして順番を変更できます',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38)),
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: editableCategories.length,
                      onReorder: (oldIndex, newIndex) {
                        setSheetState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = editableCategories.removeAt(oldIndex);
                          editableCategories.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final cat = editableCategories[index];
                        final name = cat['name'] as String;
                        return ListTile(
                          key: ValueKey(cat['id']),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF555555).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.label_outline,
                                size: 18, color: Color(0xFF555555)),
                          ),
                          title: Text(name,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500)),
                          trailing: Icon(Icons.drag_handle,
                              color: isDark ? Colors.white38 : Colors.black38),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Ticker and chart modal removed in favor of marquee

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    if (_isLoadingCategories) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: const Center(child: CircularProgressIndicator(color: const Color(0xFF555555))),
      );
    }

    final tabs = <Widget>[
      const Tab(text: 'すべて'),
      ..._categories.map((c) {
        final name = c['name'] as String;
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name),
              if (c['id'] == 51 && !context.watch<AppState>().isPremium) ...[
                const SizedBox(width: 4),
                Icon(Icons.lock, size: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              ],
            ],
          ),
        );
      }),
    ];

    // Build TabViews - Intercept Weekly Report (ID 51) for non-premium users
    final isPremium = context.watch<AppState>().isPremium;
    final tabViews = <Widget>[
      _ArticleList(
        key: const ValueKey('all'),
        categoryId: null,
        categoryName: 'すべて',
        searchQuery: _searchQuery,
        isPremium: isPremium,
      ),
      ..._categories.map<Widget>((c) {
        final categoryId = c['id'] as int;
        // 子カテゴリのIDもまとめて渡す（子カテゴリの記事も表示するため）
        final childIds = _categories
            .where((child) => child['parent'] == categoryId)
            .map((child) => child['id'] as int)
            .toList();
        final allIds = [categoryId, ...childIds];
        return _ArticleList(
          key: ValueKey(categoryId),
          categoryId: categoryId,
          categoryIds: allIds.length > 1 ? allIds : null,
          categoryName: c['name'] as String,
          searchQuery: _searchQuery,
          isPremium: isPremium,
        );
      }),
    ];

    return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '記事を検索...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (val) {
                    setState(() => _searchQuery = val);
                  },
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/app_logo.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Crypto Shift',
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
          centerTitle: true,
          leading: _isSearching
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          actions: [
            if (!_isSearching) ...[
              IconButton(
                icon: Icon(Icons.search, color: Theme.of(context).appBarTheme.foregroundColor),
                onPressed: () => setState(() => _isSearching = true),
              ),
              IconButton(
                icon: Icon(Icons.tune, color: Theme.of(context).appBarTheme.foregroundColor),
                tooltip: 'カテゴリを並び替え',
                onPressed: () => _showCategoryReorderSheet(context),
              ),
            ],
            if (_isSearching)
              IconButton(
                icon: Icon(Icons.clear, color: Theme.of(context).appBarTheme.foregroundColor),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const Color(0xFF555555),
            labelColor: const Color(0xFF555555),
            unselectedLabelColor: Colors.grey,
            tabs: tabs,
            onTap: (index) {
              _tabController?.animateTo(index);
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : const Color(0xFFE1E4E8),
                border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
              ),
              child: StreamBuilder<Map<String, MarketTicker>>(
                stream: _marketDataApi.tickerStream,
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {};
                  if (data.isEmpty) return const SizedBox.shrink();

                  final items = ['BTC', 'ETH', 'SOL', '日経平均', 'NYダウ', 'NASDAQ', 'S&P500', 'JPX日経400', '日経300'];
                  final List<Widget> tickerWidgets = [];
                  
                  for (final sym in items) {
                    if (data.containsKey(sym)) {
                      final t = data[sym]!;
                      final price = NumberFormat('#,###.##').format(t.currentPrice);
                      
                      if (t.priceChangePercent == 0.0) {
                        tickerWidgets.add(Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('[$sym] ¥$price', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                        ));
                      } else {
                        final isPositive = t.priceChangePercent > 0;
                        final pctStr = isPositive ? '+${t.priceChangePercent.toStringAsFixed(2)}%' : '${t.priceChangePercent.toStringAsFixed(2)}%';
                        final color = isPositive ? const Color(0xFF00C853) : const Color(0xFFFF3D00); // using more visible green/red
                        
                        tickerWidgets.add(Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(text: '[$sym] ¥$price '),
                                TextSpan(text: '($pctStr)', style: TextStyle(color: color)),
                              ],
                            ),
                          ),
                        ));
                      }
                    }
                  }
                  
                  if (tickerWidgets.isEmpty) return const SizedBox.shrink();

                  return _AutoScrollTicker(children: tickerWidgets);
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const PageScrollPhysics(),
                children: tabViews,
              ),
            ),
          ],
        ),
      );
  }
}

class _AutoScrollTicker extends StatefulWidget {
  final List<Widget> children;
  const _AutoScrollTicker({required this.children});
  @override
  State<_AutoScrollTicker> createState() => _AutoScrollTickerState();
}

class _AutoScrollTickerState extends State<_AutoScrollTicker> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (_scrollController.hasClients) {
        final delta = (elapsed - _lastElapsed).inMilliseconds * 0.06;
        _scrollController.jumpTo(_scrollController.offset + delta);
      }
      _lastElapsed = elapsed;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ticker.start();
    });
  }
  @override
  void dispose() { 
    _ticker.dispose(); 
    _scrollController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Center(child: widget.children[index % widget.children.length]);
      },
    );
  }
}

class _ArticleList extends StatefulWidget {
  final int? categoryId;
  final List<int>? categoryIds;
  final String categoryName;
  final String? searchQuery;
  final bool isPremium;

  const _ArticleList({
    super.key,
    required this.categoryId,
    this.categoryIds,
    required this.categoryName,
    this.searchQuery,
    this.isPremium = false,
  });

  @override
  State<_ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<_ArticleList> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  List<Article> _articles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadArticles(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _ArticleList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.categoryId != widget.categoryId) {
      _loadArticles(refresh: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadArticles({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _articles = [];
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      // 全ユーザーがprivate記事を含む一覧を取得（コンテンツ制限はアプリ詳細画面で制御）
      final posts = await WordPressApi.getPremiumPosts(
        page: _currentPage,
        perPage: 10,
        categoryId: widget.categoryIds == null ? widget.categoryId : null,
        categoryIds: widget.categoryIds,
        searchQuery: widget.searchQuery != null && widget.searchQuery!.isNotEmpty ? widget.searchQuery : null,
      );
      if (mounted) {
        setState(() {
          _articles = refresh ? posts : [..._articles, ...posts];
          _hasMore = posts.length == 10;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    try {
      // 全ユーザーがprivate記事を含む一覧を取得（コンテンツ制限はアプリ詳細画面で制御）
      final posts = await WordPressApi.getPremiumPosts(
        page: _currentPage,
        perPage: 10,
        categoryId: widget.categoryIds == null ? widget.categoryId : null,
        categoryIds: widget.categoryIds,
        searchQuery: widget.searchQuery != null && widget.searchQuery!.isNotEmpty ? widget.searchQuery : null,
      );
      if (mounted) {
        setState(() {
          _articles = [..._articles, ...posts];
          _hasMore = posts.length == 10;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading && _articles.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (_, __) => _buildShimmerCard(),
      );
    }

    if (_error != null && _articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white38, size: 60),
            const SizedBox(height: 16),
            Text('データを取得できません', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
              onPressed: () => _loadArticles(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF555555),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return Center(
        child: Text('記事がありません', style: TextStyle(color: Colors.white.withOpacity(0.5))),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF555555),
      backgroundColor: const Color(0xFF0D1117),
      onRefresh: () => _loadArticles(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _articles.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: const Color(0xFF555555))),
            );
          }
          return _buildArticleCard(_articles[index], index == 0, context);
        },
      ),
    );
  }

  Widget _buildShimmerCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06);
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final highlightColor = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                Container(width: 80, height: 12, color: Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 16, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: double.infinity, height: 16, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(width: 60, height: 12, color: Colors.white),
                          const Spacer(),
                          Container(width: 20, height: 20, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildArticleCard(Article article, bool isFeatured, BuildContext parentContext) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
        final borderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06);
        final textColor = isDark ? Colors.white : Colors.black87;
        final subtitleColor = isDark ? Colors.white.withOpacity(0.4) : Colors.black54;

        final dateStr = _formatDate(article.date);
        final isSaved = context.select<AppState, bool>((state) => state.isSaved(article.id));
        final isRead = context.select<AppState, bool>((state) => state.isRead(article.id));
        final isPremium = context.select<AppState, bool>((state) => state.isPremium);
        final isPremiumArticle = article.categories.contains(51) || article.categories.contains(52);
        final isLocked = isPremiumArticle && !isPremium;

    return GestureDetector(
      onTap: () {
        context.read<AppState>().markAsRead(article);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset('assets/app_logo.png', width: 16, height: 16, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                Text(
                  'Crypto Shift',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                ),
                if (isLocked) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF555555),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.lock, size: 10, color: Colors.white),
                        SizedBox(width: 3),
                        Text('プレミアム', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: TextStyle(
                          color: isRead ? textColor.withOpacity(0.5) : textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            dateStr,
                            style: TextStyle(color: subtitleColor, fontSize: 12),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              size: 20,
                              color: isSaved ? const Color(0xFF555555) : (isDark ? Colors.white54 : Colors.black54),
                            ),
                            onPressed: () => context.read<AppState>().toggleSave(article),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
                if (article.thumbnailUrl != null) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: article.thumbnailUrl!,
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                          color: (isRead || isLocked) ? Colors.black.withOpacity(0.5) : null,
                          colorBlendMode: (isRead || isLocked) ? BlendMode.darken : null,
                          memCacheWidth: 250,
                          placeholder: (context, url) => Container(
                            height: 90,
                            width: 90,
                            color: const Color(0xFF0D1117),
                            child: const Center(child: CircularProgressIndicator(color: const Color(0xFF555555), strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 90,
                            width: 90,
                            color: const Color(0xFF0D1117),
                            child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 24),
                          ),
                        ),
                        if (isLocked)
                          const Positioned.fill(
                            child: Center(
                              child: Icon(Icons.lock, color: Colors.white, size: 24),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd', 'ja').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

class _PremiumLockPlaceholder extends StatelessWidget {
  const _PremiumLockPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          const SizedBox(height: 24),
          const Text(
            'ウィークリーレポート',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'このコンテンツはプレミアムプラン限定です。\n加入すると最新の市場分析レポートが読み放題になります。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumPaywallScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF555555),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('プレミアムプランの詳細を見る', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
