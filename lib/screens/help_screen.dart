import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('ヘルプ・使い方', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('基本機能の使い方', textColor),
          _buildCard(
            cardColor,
            children: [
              _buildHelpItem('保存といいね機能', '記事詳細や一覧画面のアイコンをタップすると、後で読みたい記事を保存したり「いいね」をつけたりできます。マイページからいつでも見返すことが可能です。', textColor, subtitleColor, Icons.bookmark),
              const Divider(),
              _buildHelpItem('カテゴリの並べ替え', 'ホーム画面上部のカテゴリ（すべて、仮想通貨など）は、長押し（ロングタップ）したまま左右に動かすことで、お好みの順番に並べ替えることができます。', textColor, subtitleColor, Icons.swipe),
              const Divider(),
              _buildHelpItem('表示設定の変更', 'マイページ上部のアイコンから、画面の「ダークモード切替」や「文字サイズ変更（標準・大・特大）」が行えます。読みやすい環境に調整してください。', textColor, subtitleColor, Icons.text_fields),
              const Divider(),
              _buildHelpItem('最新情報の更新', '記事一覧画面で、画面を一番上からさらに下へ引っ張る（スワイプダウンする）ことで、最新の記事データを読み込むことができます。', textColor, subtitleColor, Icons.refresh),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('よくある質問 (FAQ)', textColor),
          _buildCard(
            cardColor,
            children: [
              _buildFaqItem('Q. 株価や指標の（）表記がない、または変動しないのはなぜですか？', 'A. 土日や祝日など、対象の金融市場が閉まっている（休場している）時間帯は価格が変動しないため、表示を省略しています。', textColor, subtitleColor),
              const Divider(),
              _buildFaqItem('Q. 閲覧履歴はいつまで残りますか？', 'A. 端末の容量を圧迫しないよう、閲覧履歴は自動的に直近の100件まで保持される仕組みになっています。', textColor, subtitleColor),
              const Divider(),
              _buildFaqItem('Q. アプリの通知を止めたいです', 'A. お使いのスマートフォンの「設定」アプリ ＞「通知」＞「Crypto Shift」から、プッシュ通知のオン/オフを切り替えることができます。', textColor, subtitleColor),
              const Divider(),
              _buildFaqItem('Q. プレミアムプランでできること・解約方法', 'A. 【機能】AIチャットの無制限利用などの限定機能がご利用いただけます。\n【解約】解約手続きは、ご利用のAndroid端末の「Google Playストア」アプリを開き、右上のプロフィールアイコン ＞「お支払いと定期購入」＞「定期購入」からいつでも行うことができます。', textColor, subtitleColor),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('お問い合わせ・その他', textColor),
          _buildCard(
            cardColor,
            children: [
              ListTile(
                leading: Icon(Icons.mail_outline, color: textColor),
                title: Text('お問い合わせ', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text('不具合のご報告やご要望など', style: TextStyle(color: subtitleColor, fontSize: 13)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () async {
                  final url = Uri.parse('https://crypto-shift.com/%E3%81%8A%E5%95%8F%E3%81%84%E5%90%88%E3%82%8F%E3%81%9B');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.info_outline, color: textColor),
                title: Text('アプリバージョン', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                trailing: Text('1.1.0', style: TextStyle(color: subtitleColor, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCard(Color cardColor, {required List<Widget> children}) {
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildHelpItem(String title, String desc, Color textColor, Color subtitleColor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00D2FF), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String q, String a, Color textColor, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Q.', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A.', style: TextStyle(color: const Color(0xFF00D2FF), fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  a,
                  style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
