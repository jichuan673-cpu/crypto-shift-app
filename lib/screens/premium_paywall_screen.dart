import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class PremiumPaywallScreen extends StatelessWidget {
  const PremiumPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('プレミアムプラン', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Color(0xFF00D2FF)),
            const SizedBox(height: 16),
            Text(
              'Crypto Shift プレミアム',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '投資の意思決定を加速する、\nあなた専用のAI金融アナリスト。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: subtitleColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // Feature List
            _buildFeatureRow(Icons.chat_bubble_outline, 'AIチャットボット使い放題', '過去の膨大な記事データに基づき、あらゆる疑問にアナリストが即答します。', textColor, subtitleColor),
            const SizedBox(height: 24),
            _buildFeatureRow(Icons.notifications_active_outlined, 'キーワード指定のカスタム通知', '「ETF」「税金」など、気になるキーワードのニュースが出た時だけ通知を受け取れます。', textColor, subtitleColor),
            const SizedBox(height: 24),
            _buildFeatureRow(Icons.summarize_outlined, '週末のAI週間レポート配信', '多忙なあなたに代わり、1週間の重要な金融・仮想通貨ニュースをAIがまとめてお届けします。', textColor, subtitleColor),
            const SizedBox(height: 24),
            _buildFeatureRow(Icons.block, '広告の完全非表示', '一切の広告を排除し、最高に快適な情報収集体験を提供します。', textColor, subtitleColor),

            const SizedBox(height: 48),

            // Pricing
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.5), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    '月額 500円',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'いつでも解約可能です',
                    style: TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subscribe Button
            ElevatedButton(
              onPressed: () {
                // TODO: RevenueCat integration in Phase 2
                // For Phase 1 (mock), simply upgrade the user for testing.
                context.read<AppState>().setPremiumStatus(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('【テスト用】プレミアムプランに登録しました！')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'プレミアムに登録する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Implement restore purchases for RevenueCat
              },
              child: Text(
                '購入を復元する',
                style: TextStyle(color: subtitleColor),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description, Color textColor, Color subtitleColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00D2FF), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
