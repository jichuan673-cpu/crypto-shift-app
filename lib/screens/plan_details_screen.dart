import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class PlanDetailsScreen extends StatelessWidget {
  const PlanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final joinDate = appState.premiumJoinDate.isNotEmpty ? appState.premiumJoinDate : "不明";

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('プラン詳細', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard(
            title: 'プラン加入状況',
            cardColor: cardColor,
            textColor: textColor,
            children: [
              Text(
                '現在PREMIUMプランをご利用中です。',
                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '加入日: $joinDate',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'プランでできること',
            cardColor: cardColor,
            textColor: textColor,
            children: [
              _buildFeatureItem('AIチャットの利用回数大幅アップ（1日30回）', textColor),
              _buildFeatureItem('ウィークリーレポート等、すべての限定記事の閲覧', textColor),
              _buildFeatureItem('お好み通知（頻度やカテゴリ）の自由なカスタマイズ', textColor),
              _buildFeatureItem('アプリ内の広告を完全に非表示', textColor),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'プラン解約方法',
            cardColor: cardColor,
            textColor: textColor,
            children: [
              Text(
                'Google Playストアアプリの「お支払いと定期購入」＞「定期購入」からいつでも解約手続きが可能です。\n解約後も次回の更新日までは引き続きプレミアム機能をご利用いただけます。',
                style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color cardColor,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('・', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
