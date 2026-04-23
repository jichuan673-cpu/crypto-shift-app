import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Crypto Shift について', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/app_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Crypto Shift',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '次世代の金融シフトを読み解く羅針盤',
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _buildSectionTitle('Mission - 私たちの理念', textColor),
              const SizedBox(height: 12),
              _buildBodyText(
                'Crypto Shiftは、暗号資産（仮想通貨）とマクロ経済、地政学、そしてグローバル金融システムの最前線を捉え、読者の皆様に本質的で鋭い洞察（インサイト）をお届けするデジタルメディアです。',
                textColor,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('編集方針', textColor),
              const SizedBox(height: 12),
              _buildBodyText(
                '単なる投機的な価格の上下にとどまらず、新しいデジタル資産テクノロジーが「既存の金融システム構造をいかに変革していくのか（シフトしていくのか）」という視点を最も重視しています。\n\n'
                '機関投資家の動向をはじめ、中央銀行デジタル通貨（CBDC）の波、現実資産のトークン化（RWA）、そして変わりゆく法規制など。\n'
                '私たちはビジネスプロフェッショナルから投資家の方々まで、これからの不確実な経済パラダイムシフトを読み解くための確かな「羅針盤」であり続けます。',
                textColor,
              ),
              const SizedBox(height: 48),
              Center(
                child: Text(
                  '© Crypto Shift Editorial Department',
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildBodyText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        height: 1.8,
        color: color.withOpacity(0.9),
      ),
    );
  }
}
