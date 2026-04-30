import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';
import 'about_screen.dart';
import 'help_screen.dart';
import 'notification_settings_screen.dart';
import 'premium_paywall_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('マイページ', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.format_size),
              tooltip: '文字サイズ変更',
              onPressed: () {
                final current = context.read<AppState>().fontSizeMultiplier;
                // Cycle: 1.0 -> 1.2 -> 1.4 -> 1.0
                double next = 1.0;
                if (current == 1.0) next = 1.2;
                else if (current == 1.2) next = 1.4;
                context.read<AppState>().changeFontSize(next);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('文字サイズを ${next == 1.0 ? "標準" : next == 1.2 ? "大" : "特大"} に変更しました'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                context.watch<AppState>().isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                context.read<AppState>().toggleTheme();
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'その他',
              onSelected: (value) async {
                if (value == 'notifications') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                  );
                } else if (value == 'help') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                } else if (value == 'about') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                } else if (value == 'privacy') {
                  final url = Uri.parse('https://crypto-shift.com/privacy-policy/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                } else if (value == 'terms') {
                  final url = Uri.parse('https://crypto-shift.com/%e5%88%a9%e7%94%a8%e8%a6%8f%e7%b4%84/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'notifications',
                  child: Text('通知設定'),
                ),
                const PopupMenuItem(
                  value: 'help',
                  child: Text('ヘルプ・使い方'),
                ),
                const PopupMenuItem(
                  value: 'about',
                  child: Text('Crypto Shift について'),
                ),
                const PopupMenuItem(
                  value: 'privacy',
                  child: Text('プライバシーポリシー'),
                ),
                const PopupMenuItem(
                  value: 'terms',
                  child: Text('利用規約'),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF00D2FF),
            labelColor: Color(0xFF00D2FF),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: '保存済み'),
              Tab(text: 'いいね'),
              Tab(text: '閲覧履歴'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildPremiumStatus(context),
            const Expanded(
              child: TabBarView(
                children: [
                  _ArticleListTab(tabType: _TabType.saved),
                  _ArticleListTab(tabType: _TabType.liked),
                  _ArticleListTab(tabType: _TabType.read),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatus(BuildContext context) {
    final isPremium = context.watch<AppState>().isPremium;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? const Color(0xFF161B22) : Colors.white,
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.workspace_premium : Icons.stars,
            color: isPremium ? Colors.amber : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'プレミアムプラン 加入中' : '無料プラン',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isPremium ? '全ての機能が使い放題です' : 'AIチャットが1日3回まで利用可能です',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumPaywallScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00D2FF),
            ),
            child: Text(isPremium ? 'プラン詳細・解約' : 'アップグレード'),
          ),
        ],
      ),
    );
  }
}

enum _TabType { saved, liked, read }

class _ArticleListTab extends StatelessWidget {
  final _TabType tabType;

  const _ArticleListTab({required this.tabType});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        List<Article> articles;
        String emptyMessage;

        switch (tabType) {
          case _TabType.saved:
            articles = appState.getSavedArticles();
            emptyMessage = '保存した記事はありません';
            break;
          case _TabType.liked:
            articles = appState.getLikedArticles();
            emptyMessage = 'いいねした記事はありません';
            break;
          case _TabType.read:
            articles = appState.getReadArticles();
            emptyMessage = '閲覧履歴はありません';
            break;
        }

        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tabType == _TabType.saved
                      ? Icons.bookmark_border
                      : tabType == _TabType.liked
                          ? Icons.favorite_border
                          : Icons.history,
                  size: 64,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: articles.length,
          separatorBuilder: (_, __) => Divider(
            color: Colors.white.withOpacity(0.05),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final article = articles[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(article: article),
                  ),
                );
              },
              title: Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      tabType == _TabType.saved
                          ? Icons.bookmark
                          : tabType == _TabType.liked
                              ? Icons.favorite
                              : Icons.access_time,
                      size: 14,
                      color: const Color(0xFF00D2FF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(article.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd HH:mm', 'ja').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
