import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: const Text('プライバシーポリシー',
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
              'Crypto Shift（以下「本アプリ」）は、ユーザーのプライバシーを尊重し、個人情報の保護に努めます。本ポリシーは、本アプリが収集する情報とその利用方法について説明します。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('1. 収集する情報', textColor, cardColor, [
            _buildItem('通知設定情報', '通知の頻度・カテゴリ選択などの設定情報をお客様のデバイス内に保存します。', subtitleColor),
            _buildItem('利用履歴', '閲覧した記事・保存した記事・いいねした記事の履歴をデバイス内に保存します。', subtitleColor),
            _buildItem('デバイストークン', 'プッシュ通知の配信のため、Firebase Cloud Messaging（FCM）のデバイストークンを利用します。', subtitleColor),
            _buildItem('購入情報', 'プレミアムプランの購入・管理のため、Google Play の購入情報を RevenueCat を通じて処理します。', subtitleColor),
          ]),
          const SizedBox(height: 16),

          _buildSection('2. 情報の利用目的', textColor, cardColor, [
            _buildBullet('記事・コンテンツの提供', subtitleColor),
            _buildBullet('プッシュ通知の配信', subtitleColor),
            _buildBullet('プレミアムプランの管理', subtitleColor),
            _buildBullet('AIチャット機能の提供', subtitleColor),
            _buildBullet('アプリの改善・不具合対応', subtitleColor),
          ]),
          const SizedBox(height: 16),

          _buildSection('3. 第三者サービスの利用', textColor, cardColor, [
            _buildItem('Firebase（Google LLC）',
                'プッシュ通知・アプリ基盤として利用しています。Googleのプライバシーポリシーが適用されます。', subtitleColor),
            _buildItem('RevenueCat Inc.',
                'プレミアムプランの購入管理に利用しています。RevenueCatのプライバシーポリシーが適用されます。', subtitleColor),
            _buildItem('WordPress REST API',
                '記事コンテンツの取得に利用しています。サーバー側のアクセスログが記録される場合があります。', subtitleColor),
          ]),
          const SizedBox(height: 16),

          _buildSection('4. 情報の第三者提供', textColor, cardColor, [
            _buildText(
              '本アプリは、法令に基づく場合または上記第三者サービスの利用を除き、ユーザーの個人情報を第三者に提供・開示しません。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('5. 情報の管理・削除', textColor, cardColor, [
            _buildText(
              'アプリをアンインストールすることで、デバイス内に保存された利用履歴・設定情報はすべて削除されます。サーバー側のデータ削除をご希望の場合は、お問い合わせフォームよりご連絡ください。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('6. 未成年者の利用', textColor, cardColor, [
            _buildText(
              '本アプリは13歳未満のお子様を対象としておりません。13歳未満の方の個人情報を意図的に収集することはありません。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('7. ポリシーの変更', textColor, cardColor, [
            _buildText(
              '本プライバシーポリシーは予告なく変更される場合があります。重要な変更が生じた場合は、アプリ内でお知らせします。',
              subtitleColor,
            ),
          ]),
          const SizedBox(height: 16),

          _buildSection('8. お問い合わせ', textColor, cardColor, [
            _buildText(
              'プライバシーに関するご質問・ご要望は、アプリ内のヘルプページのお問い合わせフォームよりご連絡ください。',
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
