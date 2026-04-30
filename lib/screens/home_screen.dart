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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSearching = false;
  String _searchQuery = '';
  
  late final MarketDataApi _marketDataApi;

  @override
  void initState() {
    super.initState();
    _marketDataApi = MarketDataApi()..connect();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final savedOrder = context.read<AppState>().categoryOrder;
    final cats = await WordPressApi.getCategories();
    
    if (savedOrder.isNotEmpty) {
      cats.sort((a, b) {
        final aIndex = savedOrder.indexOf(a['name'] as String);
        final bIndex = savedOrder.indexOf(b['name'] as String);
        if (aIndex == -1 && bIndex == -1) return 0;
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });
    }

    if (mounted) {
      setState(() {
        _categories = cats;
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
    _searchController.dispose();
    _marketDataApi.dispose();
    super.dispose();
  }

  // Ticker and chart modal removed in favor of marquee

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    if (_isLoadingCategories) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF))),
      );
    }

    final tabs = <Widget>[
      const Tab(text: 'すべて'),
      ..._categories.asMap().entries.map((e) {
        final int index = e.key;
        final c = e.value;
        final name = c['name'] as String;
        
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) => details.data != index,
          onAcceptWithDetails: (details) {
            final fromIndex = details.data;
            setState(() {
              final item = _categories.removeAt(fromIndex);
              _categories.insert(index, item);
            });
            context.read<AppState>().updateCategoryOrder(_categories.map((cat) => cat['name'] as String).toList());
          },
          builder: (context, candidateData, rejectedData) {
            final isHovered = candidateData.isNotEmpty;
            return LongPressDraggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D2FF).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Tab(text: name),
              ),
              child: Container(
                decoration: isHovered
                    ? const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF00D2FF), width: 3)),
                      )
                    : null,
                child: Tab(text: name),
              ),
            );
          },
        );
      }),
    ];

    final tabViews = [
      _ArticleList(categoryId: null, categoryName: 'すべて', searchQuery: _searchQuery),
      ..._categories.map((c) => _ArticleList(
            categoryId: c['id'] as int,
            categoryName: c['name'] as String,
            searchQuery: _searchQuery,
          )),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
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
            if (!_isSearching)
              IconButton(
                icon: Icon(Icons.search, color: Theme.of(context).appBarTheme.foregroundColor),
                onPressed: () => setState(() => _isSearching = true),
              ),
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
            isScrollable: true,
            indicatorColor: const Color(0xFF00D2FF),
            labelColor: const Color(0xFF00D2FF),
            unselectedLabelColor: Colors.grey,
            tabs: tabs,
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
                children: tabViews,
              ),
            ),
          ],
        ),
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
  final String categoryName;
  final String? searchQuery;

  const _ArticleList({
    required this.categoryId,
    required this.categoryName,
    this.searchQuery,
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
    if (oldWidget.searchQuery != widget.searchQuery) {
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
      final posts = await WordPressApi.getPosts(
        page: _currentPage,
        perPage: 10,
        categoryId: widget.categoryId,
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
      final posts = await WordPressApi.getPosts(
        page: _currentPage,
        perPage: 10,
        categoryId: widget.categoryId,
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
                backgroundColor: const Color(0xFF00D2FF),
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
      color: const Color(0xFF00D2FF),
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
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF))),
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
                              color: isSaved ? const Color(0xFF00D2FF) : (isDark ? Colors.white54 : Colors.black54),
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
                    child: CachedNetworkImage(
                      imageUrl: article.thumbnailUrl!,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                      color: isRead ? Colors.black.withOpacity(0.5) : null,
                      colorBlendMode: isRead ? BlendMode.darken : null,
                      memCacheWidth: 250, // Optimize image memory for thumbnail
                      placeholder: (context, url) => Container(
                        height: 90,
                        width: 90,
                        color: const Color(0xFF0D1117),
                        child: const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF), strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 90,
                        width: 90,
                        color: const Color(0xFF0D1117),
                        child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 24),
                      ),
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
