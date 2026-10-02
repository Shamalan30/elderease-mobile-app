import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Wraps flutter_local_notifications so the rest of the app never has to
/// deal with plugin details directly. Handles:
/// - Requesting notification permissions (Android 13+)
/// - Creating the "Remindly Reminders" notification channel
/// - Scheduling / cancelling reminders for tasks and appointments
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'remindly_reminders';
  static const String _channelName = 'ElderEase Reminders';
  static const String _channelDescription = 'Reminders for your tasks and appointments';

  bool _initialized = false;

  /// Call once, early in app startup (before runApp or in main()).
  Future<void> init() async {
    if (_initialized) return;

    // Set up timezone database so scheduled times are correct
    // regardless of device timezone.
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(await _deviceTimeZoneName()));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Create the high-importance Android notification channel.
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// Returns the device's IANA timezone name, e.g. "Asia/Kuala_Lumpur".
  /// Falls back to UTC if it can't be determined.
  Future<String> _deviceTimeZoneName() async {
    try {
      // Malaysia is fixed at Asia/Kuala_Lumpur (no daylight saving), so we
      // hardcode it here for reliability in this MVP instead of adding
      // another package just to detect it.
      return 'Asia/Kuala_Lumpur';
    } catch (_) {
      return 'UTC';
    }
  }

  /// Requests notification permission on Android 13+ (API 33+).
  /// Older Android versions grant this automatically at install time.
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Requests the "exact alarm" permission needed on Android 12+ to fire
  /// reminders at the precise scheduled time.
  Future<void> requestExactAlarmPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// Schedules a single reminder notification.
  /// [id] must be a unique, stable integer per task/appointment reminder
  /// (used later to cancel or update it).
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    if (!_initialized) await init();

    final scheduledTz = tz.TZDateTime.from(scheduledDateTime, tz.local);

    // Don't try to schedule something in the past.
    if (scheduledTz.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}