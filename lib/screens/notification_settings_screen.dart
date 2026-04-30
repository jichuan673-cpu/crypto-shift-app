import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/wordpress_api.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await WordPressApi.getCategories();
    if (mounted) {
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('通知設定', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('プッシュ通知の受信', textColor),
          _buildCard(
            cardColor,
            children: [
              SwitchListTile(
                title: Text('通知を受け取る', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                subtitle: Text('新着記事や重要なお知らせを受け取ります', style: TextStyle(color: subtitleColor, fontSize: 12)),
                activeColor: const Color(0xFF00D2FF),
                value: appState.notificationsEnabled,
                onChanged: (val) {
                  appState.setNotificationsEnabled(val);
                },
              ),
            ],
          ),
          
          if (appState.notificationsEnabled) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('配信頻度の選択', textColor),
            _buildCard(
              cardColor,
              children: [
                RadioListTile<String>(
                  title: Text('リアルタイム', style: TextStyle(color: textColor)),
                  subtitle: Text('記事が追加されるたびに通知します', style: TextStyle(color: subtitleColor, fontSize: 12)),
                  value: 'realtime',
                  groupValue: appState.notificationFrequency,
                  activeColor: const Color(0xFF00D2FF),
                  onChanged: (val) {
                    if (val != null) appState.setNotificationFrequency(val);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text('1日1回のまとめ (ダイジェスト)', style: TextStyle(color: textColor)),
                  subtitle: Text('1日の新着記事をまとめて1回だけ通知します', style: TextStyle(color: subtitleColor, fontSize: 12)),
                  value: 'daily',
                  groupValue: appState.notificationFrequency,
                  activeColor: const Color(0xFF00D2FF),
                  onChanged: (val) {
                    if (val != null) appState.setNotificationFrequency(val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('受信するカテゴリの選択', textColor),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                '※ すべてオフの場合はすべてのカテゴリの通知が届きます',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
                ),
              )
            else
              _buildCard(
                cardColor,
                children: _categories.map((cat) {
                  final catId = cat['id'] as int;
                  final isSelected = appState.subscribedCategoryIds.contains(catId);
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(cat['name'] as String, style: TextStyle(color: textColor)),
                        activeColor: const Color(0xFF00D2FF),
                        value: isSelected,
                        onChanged: (val) {
                          appState.toggleSubscribedCategory(catId);
                        },
                      ),
                      if (cat != _categories.last) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
          ],
          
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
}
