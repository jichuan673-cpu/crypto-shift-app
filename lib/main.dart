import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_state.dart';
import 'screens/root_screen.dart';
import 'services/revenuecat_service.dart';
import 'services/notification_service.dart';

/// バックグラウンドFCMメッセージハンドラ
/// ※ notification ペイロードがある場合はOSが自動表示するため介入不可
/// ※ data-only メッセージの場合はここでフィルタして表示制御する
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // notification ペイロード付き → OS が自動表示（介入不可）
  // data-only メッセージのみ以下の処理を行う
  if (message.notification != null) return;

  final prefs = await SharedPreferences.getInstance();

  // 通知オフなら表示しない
  if (!(prefs.getBool('notificationsEnabled') ?? true)) return;

  // スケジュール設定の場合はリアルタイムFCMを表示しない
  final frequency = prefs.getString('notificationFrequency') ?? 'realtime';
  if (frequency == 'scheduled') return;

  // カテゴリフィルタ
  final subscribedCategories =
      prefs.getStringList('subscribedCategoryIds') ?? [];
  if (subscribedCategories.isNotEmpty) {
    final catStr =
        message.data['categories'] ?? message.data['category'] ?? '';
    if (catStr.isNotEmpty) {
      final msgCats = catStr.split(',').map((s) => s.trim()).toList();
      final hasMatch = subscribedCategories.any((id) => msgCats.contains(id));
      if (!hasMatch) return;
    }
  }

  // ローカル通知として表示
  await NotificationService.initialize();
  await NotificationService.showForegroundNotification(
    title: message.data['title'] ?? '新着記事',
    body: message.data['body'] ?? 'Crypto Shiftに新しい記事が届きました',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialize
  try {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase initialization passed (requires config): $e');
  }

  // LocalNotifications Initialize
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('NotificationService initialization error: $e');
  }

  // RevenueCat Initialize
  try {
    await RevenueCatService.init();
  } catch (e) {
    debugPrint('RevenueCat initialization passed (requires config): $e');
  }

  await initializeDateFormatting('ja', null);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const CryptoShiftApp(),
    ),
  );
}

class CryptoShiftApp extends StatelessWidget {
  const CryptoShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Crypto Shift',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ja', 'JP'),
          supportedLocales: const [
            Locale('ja', 'JP'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF555555),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.notoSerifJpTextTheme(ThemeData.dark().textTheme),
            scaffoldBackgroundColor: const Color(0xFF0A0E1A),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D1117),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF555555),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.notoSerifJpTextTheme(ThemeData.light().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          home: FcmListenerWidget(child: const RootScreen()),
        );
      },
    );
  }
}

/// FCMフォアグラウンド通知を処理するウィジェット
class FcmListenerWidget extends StatefulWidget {
  final Widget child;
  const FcmListenerWidget({super.key, required this.child});
  @override
  State<FcmListenerWidget> createState() => _FcmListenerWidgetState();
}

class _FcmListenerWidgetState extends State<FcmListenerWidget> {
  @override
  void initState() {
    super.initState();

    // フォアグラウンド受信時：ユーザー設定に基づいてフィルタして表示
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final appState = context.read<AppState>();

      // 通知オフなら表示しない
      if (!appState.notificationsEnabled) return;

      // スケジュール設定の場合はリアルタイムFCMを表示しない
      // （代わりに指定時刻にローカル通知が届く）
      if (appState.notificationFrequency == 'scheduled') return;

      // カテゴリフィルタ（メッセージのdataにcategoriesが含まれる場合）
      final subscribedIds = appState.subscribedCategoryIds;
      if (subscribedIds.isNotEmpty) {
        final catStr =
            message.data['categories'] ?? message.data['category'] ?? '';
        if (catStr.isNotEmpty) {
          final msgCats = catStr
              .split(',')
              .map((s) => int.tryParse(s.trim()))
              .whereType<int>()
              .toList();
          final hasMatch = msgCats.any((cat) => subscribedIds.contains(cat));
          if (!hasMatch) return;
        }
      }

      final title = message.notification?.title ??
          message.data['title'] ??
          '新着記事';
      final body = message.notification?.body ??
          message.data['body'] ??
          'Crypto Shiftに新しい記事が届きました';
      NotificationService.showForegroundNotification(
          title: title, body: body);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
