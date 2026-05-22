import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = '不具合のご報告';
  bool _isSending = false;

  static const _contactEmail = 'info@crypto-shift.com';

  final List<String> _categories = [
    '不具合のご報告',
    '機能のご要望',
    'プレミアムプランについて',
    '記事・コンテンツについて',
    'その他',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final category = _selectedCategory;
    final message = _messageController.text.trim();

    final subject = Uri.encodeComponent(
        '[Crypto Shift] $category');
    final body = Uri.encodeComponent(
        'お名前: $name\nメールアドレス: $email\nお問い合わせ種別: $category\n\n【お問い合わせ内容】\n$message');

    final mailUri = Uri.parse(
        'mailto:$_contactEmail?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(mailUri)) {
        await launchUrl(mailUri);
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          _showErrorDialog('メールアプリを開けませんでした。\n$_contactEmail に直接メールをお送りください。');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('エラーが発生しました。\n$_contactEmail に直接メールをお送りください。');
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('メールアプリを起動しました'),
        content: const Text(
            'メールアプリで内容を確認して送信してください。\n\n通常3営業日以内にご返信いたします。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ダイアログを閉じる
              Navigator.pop(context); // フォーム画面を閉じる
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF555555))),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる', style: TextStyle(color: Color(0xFF555555))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final fillColor = isDark ? const Color(0xFF1C212B) : const Color(0xFFF8F9FA);
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('お問い合わせ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 説明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: const Color(0xFF555555), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'お問い合わせ内容を入力後、メールアプリで送信してください。通常3営業日以内にご返信します。',
                      style: TextStyle(
                          color: subtitleColor, fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // お名前
            _buildLabel('お名前', textColor, required: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: _inputDecoration(
                  'お名前を入力してください', fillColor, borderColor, subtitleColor),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'お名前を入力してください' : null,
            ),
            const SizedBox(height: 20),

            // メールアドレス
            _buildLabel('返信先メールアドレス', textColor, required: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
              decoration: _inputDecoration(
                  'example@email.com', fillColor, borderColor, subtitleColor),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'メールアドレスを入力してください';
                if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v.trim())) {
                  return '正しいメールアドレスを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // お問い合わせ種別
            _buildLabel('お問い合わせの種類', textColor, required: true),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor, fontSize: 15),
                  icon: Icon(Icons.keyboard_arrow_down, color: subtitleColor),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCategory = v);
                  },
                  items: _categories
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style: TextStyle(color: textColor, fontSize: 15))))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // お問い合わせ内容
            _buildLabel('お問い合わせ内容', textColor, required: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _messageController,
              style: TextStyle(color: textColor),
              maxLines: 7,
              decoration: _inputDecoration(
                  'お問い合わせの内容を具体的にご記入ください',
                  fillColor,
                  borderColor,
                  subtitleColor),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? '10文字以上でお問い合わせ内容を入力してください'
                  : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_messageController.text.length} 文字',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),

            // 送信ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _submit,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, size: 18),
                label: Text(
                  _isSending ? '準備中...' : 'メールアプリで送信する',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF555555),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  disabledBackgroundColor:
                      const Color(0xFF555555).withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 直接メール案内
            Center(
              child: Text(
                '直接メールでのお問い合わせ: $_contactEmail',
                style: TextStyle(color: subtitleColor, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, Color color, {bool required = false}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w600)),
        if (required) ...[
          const SizedBox(width: 4),
          const Text('*',
              style: TextStyle(color: Color(0xFFE53935), fontSize: 14)),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(
      String hint, Color fill, Color border, Color hintColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      filled: true,
      fillColor: fill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF555555), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
    );
  }
}
