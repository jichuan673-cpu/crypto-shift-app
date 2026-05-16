import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/wordpress_api.dart';
import 'premium_paywall_screen.dart';

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
        _categories = cats.where((c) => (c['name'] as String).toLowerCase() != 'premium').toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickScheduledTime(BuildContext context, AppState appState) async {
    final parts = appState.notificationScheduledTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      appState.setNotificationScheduledTime(timeStr);
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
                activeColor: const Color(0xFF555555),
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
                // リアルタイム（全員利用可能）
                RadioListTile<String>(
                  title: Text('リアルタイム', style: TextStyle(color: textColor)),
                  subtitle: Text('記事が追加されるたびに通知します', style: TextStyle(color: subtitleColor, fontSize: 12)),
                  value: 'realtime',
                  groupValue: appState.notificationFrequency,
                  activeColor: const Color(0xFF555555),
                  onChanged: (val) {
                    if (val != null) appState.setNotificationFrequency(val);
                  },
                ),
                const Divider(height: 1),
                // 時間指定（プレミアム限定）
                if (appState.isPremium) ...[
                  RadioListTile<String>(
                    title: Text('時間指定', style: TextStyle(color: textColor)),
                    subtitle: Text('指定した時間に新着記事をまとめて通知します', style: TextStyle(color: subtitleColor, fontSize: 12)),
                    value: 'scheduled',
                    groupValue: appState.notificationFrequency,
                    activeColor: const Color(0xFF555555),
                    onChanged: (val) {
                      if (val != null) appState.setNotificationFrequency(val);
                    },
                  ),
                  if (appState.notificationFrequency == 'scheduled') ...[
                    const Divider(height: 1),
                    InkWell(
                      onTap: () => _pickScheduledTime(context, appState),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 20, color: const Color(0xFF555555)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('配信時間', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text('タップして時間を変更', style: TextStyle(color: subtitleColor, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              appState.notificationScheduledTime,
                              style: TextStyle(
                                color: const Color(0xFF555555),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 20, color: subtitleColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  // 非プレミアム：時間指定はロック表示
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen())),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'scheduled',
                            groupValue: null,
                            onChanged: null,
                            activeColor: Colors.grey,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('時間指定', style: TextStyle(color: subtitleColor)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF555555),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('プレミアム', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('指定した時間に新着記事をまとめて通知します', style: TextStyle(color: subtitleColor, fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.lock, size: 16, color: subtitleColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),
            // カテゴリ選択セクション（タイトル）
            Row(
              children: [
                Expanded(child: _buildSectionTitle('受信するカテゴリの選択', textColor)),
                if (!appState.isPremium)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF555555),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('プレミアム', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            if (appState.isPremium) ...[
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
                    child: CircularProgressIndicator(color: const Color(0xFF555555)),
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
                          activeColor: const Color(0xFF555555),
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
            ] else ...[
              // 非プレミアム：カテゴリ選択はロックカード
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen())),
                child: _buildCard(
                  cardColor,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.lock_outline, size: 32, color: subtitleColor),
                          const SizedBox(height: 12),
                          Text(
                            'カテゴリ指定はプレミアム限定機能です',
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '受け取りたいカテゴリを個別に設定できます',
                            style: TextStyle(color: subtitleColor, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen())),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF555555),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('プレミアムプランを見る', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
