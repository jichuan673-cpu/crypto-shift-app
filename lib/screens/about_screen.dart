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
              _buildSectionTitle('1. Mission (ミッション)', textColor),
              const SizedBox(height: 12),
              _buildBodyText(
                '「次世代金融の羅針盤となり、パラダイムシフトの波を乗りこなす知見を提供する」\n\n'
                '暗号資産（仮想通貨）とマクロ経済、地政学、そしてグローバル金融システムの最前線を捉え、読者の皆様に本質的で鋭い洞察（インサイト）をお届けします。',
                textColor,
              ),
              const SizedBox(height: 32),
              
              _buildSectionTitle('2. Vision (ビジョン)', textColor),
              const SizedBox(height: 12),
              _buildBodyText(
                '「すべての人が、テクノロジーによって再構築される新しい経済圏を正しく理解し、自ら未来の選択ができる社会へ」\n\n'
                '私たちは、不透明な情報が飛び交う暗号資産業界において、最も信頼される情報のフィルターであり続けます。',
                textColor,
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('3. Value (バリュー)', textColor),
              const SizedBox(height: 12),
              _buildListText('本質主義 (Essentialism)', '単なる価格の上下や投機的なニュースに熱狂せず、背景にある技術的・経済的な「本質」を伝えます。', textColor),
              _buildListText('客観と中立 (Objectivity)', '特定のプロジェクトやポジショントークに偏らず、常にフェアで中立的なデータと事実に基づいた分析を提供します。', textColor),
              _buildListText('俯瞰的視点 (Macro-Perspective)', '暗号資産単体にとどまらず、既存の金融システム、各国の法規制、歴史的背景との繋がりを重んじます。', textColor),
              const SizedBox(height: 24),

              _buildSectionTitle('4. 編集方針 (Editorial Policy)', textColor),
              const SizedBox(height: 12),
              _buildBodyText(
                '新しいデジタル資産テクノロジーが「既存のシステム構造をいかに変革していくのか（シフトしていくのか）」という視点を最も重視しています。\n\n'
                '機関投資家の動向をはじめ、中央銀行デジタル通貨（CBDC）、現実資産のトークン化（RWA）などを扱い、ビジネスプロフェッショナルから投資家の方々まで、これからの不確実なパラダイムシフトを読み解くための一助となることをお約束します。',
                textColor,
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('5. 主な対象読者', textColor),
              const SizedBox(height: 12),
              _buildBulletPoint('マクロ経済と暗号資産のつながりを深く理解したいビジネスパーソン', textColor),
              _buildBulletPoint('新たな市場の波を的確に捉えたい投資家', textColor),
              _buildBulletPoint('Web3およびデジタル金融の未来に関心のあるすべての方々', textColor),
              const SizedBox(height: 48),

              Divider(color: textColor.withOpacity(0.1)),
              const SizedBox(height: 16),
              
              Text(
                '免責事項 (Disclaimer)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subtitleColor),
              ),
              const SizedBox(height: 8),
              Text(
                '本サービスに掲載されている情報は、学習および一般的な情報提供を目的とするものであり、特定の金融商品の売買を推奨する投資助言ではありません。暗号資産投資には高いリスクが伴います。最終的な決定は、必ずご自身の判断と責任において行っていただけますようお願い申し上げます。',
                style: TextStyle(fontSize: 12, height: 1.6, color: subtitleColor),
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
        fontSize: 18,
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
        fontSize: 14,
        height: 1.8,
        color: color.withOpacity(0.9),
      ),
    );
  }

  Widget _buildListText(String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('・$title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color.withOpacity(0.9))),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 13, height: 1.6, color: color.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✓ ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF00D2FF))),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, height: 1.5, color: color.withOpacity(0.9)))),
        ],
      ),
    );
  }
}
