import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../providers/app_state.dart';
import 'package:intl/intl.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF6F8FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark),
                _buildContent(context, isDark),
                _buildFooter(context, isDark),
                const SizedBox(height: 100), // padding for bottom bar
              ],
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomInteractionBar(context, isDark),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: article.thumbnailUrl != null ? 220 : 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      flexibleSpace: article.thumbnailUrl != null
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: article.thumbnailUrl!,
                    fit: BoxFit.cover,
                    memCacheWidth: 600,
                    placeholder: (_, __) => Container(color: const Color(0xFF161B22)),
                    errorWidget: (_, __, ___) => Container(color: const Color(0xFF161B22)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    String dateStr = '';
    try {
      final date = DateTime.parse(article.date);
      dateStr = DateFormat('yyyy年MM月dd日 HH:mm', 'ja').format(date);
    } catch (_) {
      dateStr = article.date;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final scale = context.watch<AppState>().fontSizeMultiplier;
    final textColor = isDark ? const Color(0xFFDDE1E7) : Colors.black87;
    final headingColor = isDark ? Colors.white : Colors.black;
    final dividerColor = isDark ? Colors.white24 : Colors.black12;
    final codeBgColor = isDark ? const Color(0xFF161B22) : const Color(0xFFF0F2F5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Html(
        data: article.content,
        style: {
          'body': Style(
            color: textColor,
            fontSize: FontSize(16 * scale),
            lineHeight: const LineHeight(1.8),
            fontFamily: 'Noto Serif JP, serif',
          ),
          '.summary': Style(color: textColor),
          '.lead': Style(color: textColor),
          'span': Style(color: textColor),
          'h1': Style(
            color: headingColor,
            fontWeight: FontWeight.bold,
            fontSize: FontSize(22 * scale),
            margin: Margins.only(top: 28, bottom: 12),
            border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
            padding: HtmlPaddings.only(bottom: 8),
          ),
          'h2': Style(
            color: headingColor,
            fontWeight: FontWeight.bold,
            fontSize: FontSize(20 * scale),
            margin: Margins.only(top: 24, bottom: 10),
            padding: HtmlPaddings.only(bottom: 8),
            border: const Border(left: BorderSide(color: Color(0xFF00D2FF), width: 4)),
          ),
          'h3': Style(
            color: headingColor,
            fontWeight: FontWeight.bold,
            fontSize: FontSize(18 * scale),
            margin: Margins.only(top: 20, bottom: 8),
          ),
          'p': Style(
            margin: Margins.only(bottom: 20),
            color: isDark ? const Color(0xFFCDD5E0) : Colors.black87,
          ),
          'a': Style(
            color: const Color(0xFF00D2FF),
            textDecoration: TextDecoration.none,
          ),
          'strong': Style(
            color: headingColor,
            fontWeight: FontWeight.bold,
          ),
          'img': Style(
            margin: Margins.symmetric(vertical: 16, horizontal: 0),
            padding: HtmlPaddings.zero,
            alignment: Alignment.center,
          ),
          'blockquote': Style(
            color: isDark ? Colors.white70 : Colors.black54,
            backgroundColor: codeBgColor,
            padding: HtmlPaddings.all(16),
            margin: Margins.only(bottom: 20),
            border: const Border(left: BorderSide(color: Color(0xFF7B2FBE), width: 4)),
          ),
          'code': Style(
            backgroundColor: codeBgColor,
            color: textColor, // use body text color
            fontFamily: 'Noto Serif JP, serif', // use body font
          ),
          'pre': Style(
            backgroundColor: codeBgColor,
            color: textColor, // use body text color
            padding: HtmlPaddings.all(16),
            margin: Margins.only(bottom: 20),
            border: Border.all(color: dividerColor),
            fontFamily: 'Noto Serif JP, serif', // use body font
          ),
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Divider(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('元の記事を読む'),
              onPressed: () async {
                final uri = Uri.parse(article.link);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00D2FF),
                side: const BorderSide(color: Color(0xFF00D2FF)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInteractionBar(BuildContext context, bool isDark) {
    final appState = context.watch<AppState>();
    final isLiked = appState.isLiked(article.id);
    final isSaved = appState.isSaved(article.id);

    // モックのいいね数（通常はAPIから取得しますが今回はローカル状態のみ）
    final likeCount = isLiked ? 1 : 0;
    
    final bgColor = isDark ? const Color(0xFF0D1117).withOpacity(0.95) : Colors.white.withOpacity(0.95);
    final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // いいねボタン
          InkWell(
            onTap: () => appState.toggleLike(article),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? const Color(0xFFFF4966) : iconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$likeCount',
                    style: TextStyle(
                      color: isLiked ? const Color(0xFFFF4966) : iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Row(
            children: [
              // 保存ボタン
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? const Color(0xFF00D2FF) : iconColor,
                  size: 26,
                ),
                onPressed: () => appState.toggleSave(article),
              ),
              const SizedBox(width: 8),
              // シェアボタン
              IconButton(
                icon: Icon(Icons.ios_share, color: iconColor, size: 24),
                onPressed: () {
                  Share.share('${article.title}\n${article.link}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
