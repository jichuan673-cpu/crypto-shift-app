import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _realtimeChannelId = 'realtime_channel';
  static const _scheduledChannelId = 'scheduled_channel';
  static const _scheduledNotificationId = 1;

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    // 日本時間（Asia/Tokyo = UTC+9）に明示的に設定
    // これをしないとtz.localがUTCになり、時間指定通知が9時間ずれる
    final tokyo = tz.getLocation('Asia/Tokyo');
    tz.setLocalLocation(tokyo);

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Androidの通知チャンネルを明示的に作成（システム設定に表示させるため）
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _realtimeChannelId,
        'リアルタイム通知',
        description: '新着記事のリアルタイム通知',
        importance: Importance.high,
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _scheduledChannelId,
        '時間指定通知',
        description: '指定した時間に届く新着記事まとめ通知',
        importance: Importance.high,
      ),
    );
  }

  /// FCMフォアグラウンドメッセージを受信したときにローカル通知として表示する
  static Future<void> showForegroundNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _realtimeChannelId,
      'リアルタイム通知',
      channelDescription: '新着記事のリアルタイム通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: const Color(0xFF1565C0),
    );
    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  /// 毎日指定時刻に通知をスケジュールする
  static Future<void> scheduleDaily({
    required int hour,
    required int minute,
  }) async {
    await cancelScheduled();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _scheduledChannelId,
      '時間指定通知',
      channelDescription: '指定した時間に届く新着記事まとめ通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: const Color(0xFF1565C0),
    );

    await _plugin.zonedSchedule(
      _scheduledNotificationId,
      '新着記事のお知らせ',
      '今日の暗号資産ニュースをチェックしましょう！',
      scheduled,
      const NotificationDetails(android: androidDetails),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('NotificationService: scheduled daily at $hour:$minute');
  }

  /// 時間指定通知をキャンセルする
  static Future<void> cancelScheduled() async {
    await _plugin.cancel(_scheduledNotificationId);
  }

  /// すべての通知をキャンセルする
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// 設定に応じてスケジュールを同期する
  static Future<void> syncSchedule({
    required bool enabled,
    required String frequency,
    required String scheduledTime,
  }) async {
    if (!enabled || frequency != 'scheduled') {
      await cancelScheduled();
      return;
    }
    final parts = scheduledTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    await scheduleDaily(hour: hour, minute: minute);
  }
}
