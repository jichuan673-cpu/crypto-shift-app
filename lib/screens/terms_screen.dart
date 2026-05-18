import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('利用規約',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(cardColor, [
            _buildText(
              '最終更新日：2026年5月',
              subtitleColor,
              fontSize: 12,
            ),
            const SizedBox(height: 8),
            _buildText(
              '本利用規約（以下「本規約」）は、Crypto Shift（以下「本アプリ」）の利用条件を定めるものです。本アプリをご利用いただく前に、必ず本規約をお読みください。本アプリを利用された場合、本規約に同意したものとみなします。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('第1条（サービスの内容）', textColor, cardColor, [
            _buildText(
              '本アプリは、暗号資産・金融に関するニュース記事の閲覧、AIによる相談機能、プッシュ通知などのサービスを提供します。コンテンツの内容・機能は予告なく変更される場合があります。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('第2条（プレミアムプラン）', textColor, cardColor, [
            _buildItem('料金', '月額500円（税込）。Google Play の定める決済方法によりお支払いください。', subtitleColor),
            _buildItem('自動更新', '解約しない限り、毎月自動で更新されます。', subtitleColor),
            _buildItem('解約方法', 'Google Play ストア → プロフィールアイコン → お支払いと定期購入 → 定期購入 から解約できます。解約後も有効期間終了まで機能をご利用いただけます。', subtitleColor),
            _buildItem('返金', '原則として購入済みのサービスの返金は承りません。ただし、Google Play の返金ポリシーが適用される場合があります。', subtitleColor),
          ]),
          const SizedBox(height: 16),

          _buildSection('第3条（禁止事項）', textColor, cardColor, [
            _buildBullet('本アプリのコンテンツの無断転載・複製・販売', subtitleColor),
            _buildBullet('本アプリへの不正アクセス・リバースエンジニアリング', subtitleColor),
            _buildBullet('AIチャット機能を用いた違法・有害なコンテンツの生成', subtitleColor),
            _buildBullet('他のユーザーや第三者への迷惑行為', subtitleColor),
            _buildBullet('法令または公序良俗に反する行為', subtitleColor),
            _buildBullet('その他、当社が不適切と判断する行為', subtitleColor),
          ]),
          const SizedBox(height: 16),

          _buildSection('第4条（免責事項）', textColor, cardColor, [
            _buildItem('情報の正確性',
                '本アプリが提供するニュース・情報は投資助言ではありません。情報の正確性・完全性を保証するものではなく、これに基づく投資判断の結果について責任を負いません。',
                subtitleColor),
            _buildItem('サービスの中断',
                'システムメンテナンス・障害・天災等によりサービスが中断される場合があります。これによって生じた損害について責任を負いません。',
                subtitleColor),
            _buildItem('AIチャット',
                'AIによる回答は参考情報であり、専門的な投資・法律・財務アドバイスの代替となるものではありません。',
                subtitleColor),
          ]),
          const SizedBox(height: 16),

          _buildSection('第5条（知的財産権）', textColor, cardColor, [
            _buildText(
              '本アプリおよびそのコンテンツ（デザイン・文章・プログラム等）に関する知的財産権は、当社または正当な権利者に帰属します。本規約で明示的に認められる範囲を超えた利用はできません。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('第6条（規約の変更）', textColor, cardColor, [
            _buildText(
              '当社は、必要と判断した場合、本規約を変更することができます。変更後の規約は本アプリ内に表示した時点で効力を生じ、継続利用をもって同意したものとみなします。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('第7条（準拠法・管轄）', textColor, cardColor, [
            _buildText(
              '本規約は日本法に準拠します。本アプリに関する紛争については、日本の裁判所を専属的合意管轄とします。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('第8条（お問い合わせ）', textColor, cardColor, [
            _buildText(
              '本規約に関するご質問は、アプリ内のヘルプページのお問い合わせフォームよりご連絡ください。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildCard(Color cardColor, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildSection(String title, Color titleColor, Color cardColor,
      List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: titleColor)),
        ),
        _buildCard(cardColor, children),
      ],
    );
  }

  Widget _buildItem(String title, String desc, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor.withOpacity(0.9))),
          const SizedBox(height: 4),
          Text(desc,
              style: TextStyle(
                  fontSize: 13, color: subtitleColor, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildBullet(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('・', style: TextStyle(color: color, fontSize: 13)),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: color, fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildText(String text, Color color, {double fontSize = 13}) {
    return Text(text,
        style: TextStyle(fontSize: fontSize, color: color, height: 1.6));
  }
}
