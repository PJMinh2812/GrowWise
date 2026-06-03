import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelDaily = AndroidNotificationDetails(
    'growwise_daily',
    'Nhắc nhở hàng ngày',
    channelDescription: 'Nhắc trẻ hoàn thành nhiệm vụ mỗi ngày',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _channelReward = AndroidNotificationDetails(
    'growwise_rewards',
    'Phần thưởng',
    channelDescription: 'Thông báo khi nhận xu thưởng',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static Future<void> initialize() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
    debugPrint('[Notification] initialized');
  }

  static Future<void> requestPermission() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('[Notification] permission error: $e');
    }
  }

  /// Nhắc nhở khi mở app nếu có nhiệm vụ chờ.
  static Future<void> showPendingTasksReminder({
    required String childName,
    required int pendingCount,
  }) async {
    if (!_initialized) await initialize();
    if (pendingCount == 0) return;

    await _plugin.show(
      0,
      '📋 Nhiệm vụ chờ $childName!',
      '$childName còn $pendingCount nhiệm vụ hôm nay — hoàn thành để kiếm xu nhé!',
      const NotificationDetails(
        android: _channelDaily,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Nhắc nhở hàng ngày (lặp theo chu kỳ ngày).
  static Future<void> scheduleDailyReminder({
    required String childName,
  }) async {
    if (!_initialized) await initialize();

    // Cancel previous daily notification first
    await _plugin.cancel(1);

    await _plugin.periodicallyShow(
      1,
      '🌱 GrowWise nhắc bạn!',
      '$childName đừng quên nhiệm vụ hôm nay nhé! Hoàn thành để kiếm xu! 💪',
      RepeatInterval.daily,
      const NotificationDetails(
        android: _channelDaily,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    debugPrint('[Notification] daily reminder scheduled for $childName');
  }

  /// Thông báo tức thì khi phụ huynh duyệt nhiệm vụ.
  static Future<void> showTaskApproved({
    required String taskTitle,
    required int coins,
  }) async {
    if (!_initialized) await initialize();

    await _plugin.show(
      2,
      '🎉 Nhiệm vụ được duyệt!',
      '"$taskTitle" hoàn thành — +$coins xu vào hũ!',
      const NotificationDetails(
        android: _channelReward,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
