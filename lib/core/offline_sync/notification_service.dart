import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local Voice-Assisted Reminder Scheduler using `flutter_local_notifications` + `timezone`.
/// Powers PrescribeSafe BD Bangla dosage alarms (`1+0+1` -> morning/night) and
/// daily habit/wellness reminders completely offline.
class ScheduledVoiceReminder {
  const ScheduledVoiceReminder({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.spokenMessageBn,
    required this.spokenMessageEn,
    required this.hour,
    required this.minute,
    required this.category, // 'medication' | 'habit' | 'wellness'
    this.enabled = true,
  });

  final int id;
  final String titleBn;
  final String titleEn;
  final String spokenMessageBn;
  final String spokenMessageEn;
  final int hour;
  final int minute;
  final String category;
  final bool enabled;

  String get formattedTime {
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final minStr = minute.toString().padLeft(2, '0');
    return '$h12:$minStr $amPm';
  }

  ScheduledVoiceReminder copyWith({bool? enabled, int? hour, int? minute}) {
    return ScheduledVoiceReminder(
      id: id,
      titleBn: titleBn,
      titleEn: titleEn,
      spokenMessageBn: spokenMessageBn,
      spokenMessageEn: spokenMessageEn,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      category: category,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titleBn': titleBn,
        'titleEn': titleEn,
        'spokenMessageBn': spokenMessageBn,
        'spokenMessageEn': spokenMessageEn,
        'hour': hour,
        'minute': minute,
        'category': category,
        'enabled': enabled,
      };

  factory ScheduledVoiceReminder.fromMap(Map<dynamic, dynamic> map) =>
      ScheduledVoiceReminder(
        id: (map['id'] as num).toInt(),
        titleBn: map['titleBn'] as String,
        titleEn: map['titleEn'] as String,
        spokenMessageBn: map['spokenMessageBn'] as String,
        spokenMessageEn: map['spokenMessageEn'] as String,
        hour: (map['hour'] as num).toInt(),
        minute: (map['minute'] as num).toInt(),
        category: map['category'] as String? ?? 'habit',
        enabled: map['enabled'] as bool? ?? true,
      );
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionRequested = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
      } catch (_) {}

      const androidInit = AndroidInitializationSettings(
        '@drawable/ic_stat_shuchona',
      );
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      debugPrint('SHUCHONA local notifications init note: $e');
    }
  }

  /// Requests Android 13+ (API 33+) `POST_NOTIFICATIONS` and iOS alert permissions
  /// at runtime so medication voice alarms and Blood SOS alerts are never silently blocked.
  Future<bool> requestPermissions() async {
    if (!_initialized) await init();
    if (!_initialized || kIsWeb) return false;
    _permissionRequested = true;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('SHUCHONA notification permission request note: $e');
    }
    return false;
  }

  Future<void> scheduleDailyReminder(ScheduledVoiceReminder reminder) async {
    if (!_initialized || !reminder.enabled) return;
    if (!_permissionRequested) {
      await requestPermissions();
    }
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminder.hour,
        reminder.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'shuchona_voice_alarms',
          'SHUCHONA Medication & Habit Reminders',
          channelDescription: 'Bangla voice dosage and daily health reminders',
          importance: Importance.high,
          priority: Priority.high,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        reminder.id,
        reminder.titleBn,
        reminder.spokenMessageBn,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('SHUCHONA scheduleDailyReminder graceful fallback: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  Future<void> showImmediateAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    if (!_permissionRequested) {
      await requestPermissions();
    }
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'shuchona_blood_sos',
          'SHUCHONA Emergency Alerts',
          channelDescription: 'High-priority blood SOS and urgent alerts',
          importance: Importance.max,
          priority: Priority.max,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('SHUCHONA showImmediateAlert note: $e');
    }
  }
}

