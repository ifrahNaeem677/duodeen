import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily reminders: Fajr (time set in Settings) and 9 PM goals reminder.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'duodeen_reminders',
      'DuoDeen reminders',
      channelDescription: 'Fajr and daily goal reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings: settings);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  static Future<void> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } catch (_) {}
  }

  /// Next time (today or tomorrow) at hour:minute, expressed in UTC.
  /// Repeating daily on that UTC time = same local time every day.
  static tz.TZDateTime _next(int hour, int minute) {
    final now = DateTime.now();
    var t = DateTime(now.year, now.month, now.day, hour, minute);
    if (!t.isAfter(now)) t = DateTime(now.year, now.month, now.day + 1, hour, minute);
    return tz.TZDateTime.from(t, tz.UTC);
  }

  static Future<void> scheduleDaily({required String fajrTime}) async {
    if (!_ready) return;
    try {
      final parts = fajrTime.split(':');
      final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 5;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

      await _plugin.cancel(id: 1);
      await _plugin.cancel(id: 2);

      await _plugin.zonedSchedule(
        id: 1,
        title: 'Time for Fajr 🌅',
        body: 'Wake up for Fajr. +5 points are waiting!',
        scheduledDate: _next(h, m),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      await _plugin.zonedSchedule(
        id: 2,
        title: 'Complete your goals ⏳',
        body: '1 hour left! The daily winner is decided at 10 PM.',
        scheduledDate: _next(21, 0),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
