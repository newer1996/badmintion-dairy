import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/activity.dart';
import '../services/settings_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._init();

  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化时区
    tz_data.initializeTimeZones();

    // Android 配置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 配置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // 处理通知点击
    debugPrint('Notification tapped: ${response.payload}');
  }

  // 请求权限
  Future<bool> requestPermission() async {
    final settings = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return settings ?? false;
  }

  // 调度活动提醒
  Future<void> scheduleActivityReminder(Activity activity) async {
    final appSettings = SettingsService.instance.getSettings();
    
    if (!appSettings.notificationsEnabled) {
      debugPrint('Notifications disabled, skipping reminder');
      return;
    }

    // 取消已存在的提醒
    await cancelActivityReminder(activity.id);

    // 计算提醒时间
    final scheduledDate = _calculateReminderTime(
      activity.date,
      activity.startTime,
      appSettings.reminderMinutes,
    );

    // 如果提醒时间已过，不设置
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('Reminder time in the past, skipping');
      return;
    }

    await _notifications.zonedSchedule(
      activity.id.hashCode,
      '🏸 羽毛球活动提醒',
      '${activity.startTime} 有羽毛球活动，别忘了哦！',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'activity_reminders',
          '活动提醒',
          channelDescription: '羽毛球活动开始前的提醒',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: appSettings.vibrationEnabled,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: activity.id,
    );

    debugPrint('✅ Reminder scheduled for ${activity.startTime} at $scheduledDate');
  }

  // 取消活动提醒
  Future<void> cancelActivityReminder(String activityId) async {
    await _notifications.cancel(activityId.hashCode);
  }

  // 取消所有提醒
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // 计算提醒时间
  DateTime _calculateReminderTime(DateTime date, String startTime, int reminderMinutes) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    ).subtract(Duration(minutes: reminderMinutes));
  }

  // 测试通知
  Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      '🏸 测试通知',
      '通知功能正常工作！',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          '测试',
          channelDescription: '测试通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
