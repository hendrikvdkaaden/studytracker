import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../models/goal.dart';
import '../models/study_session.dart';
import 'settings_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final locationName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _plugin.initialize(settings);
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  /// Schedule a reminder for a study session.
  /// - If session has startTime: 15 min before startTime
  /// - If no startTime: 09:00 on the session date
  /// - Notifications in the past are silently skipped
  static Future<void> scheduleSessionReminder(
    StudySession session,
    String goalTitle,
  ) async {
    try {
      final tz.TZDateTime scheduledDate;

      if (session.startTime != null) {
        final minutesBefore = SettingsService.sessionReminderMinutes;
        scheduledDate = tz.TZDateTime.from(
          session.startTime!.subtract(Duration(minutes: minutesBefore)),
          tz.local,
        );
      } else {
        scheduledDate = tz.TZDateTime(
          tz.local,
          session.date.year,
          session.date.month,
          session.date.day,
          9, // 09:00
        );
      }

      // Don't schedule if in the past
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin.zonedSchedule(
        session.id.hashCode,
        'Study session coming up',
        'Time to study "$goalTitle" - ${session.formattedDuration}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'study_sessions',
            'Study Session Reminders',
            channelDescription: 'Reminders for planned study sessions',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint('Failed to schedule session reminder: $e');
    }
  }

  /// Schedule a deadline reminder: 09:00, N days before goal.date
  static Future<void> scheduleDeadlineReminder(Goal goal) async {
    try {
      final daysBefore = SettingsService.deadlineReminderDays;
      final reminderDate = goal.date.subtract(Duration(days: daysBefore));
      final scheduledDate = tz.TZDateTime(
        tz.local,
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        9, // 09:00
      );

      // Don't schedule if in the past
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin.zonedSchedule(
        goal.id.hashCode,
        'Deadline tomorrow',
        '"${goal.title}" is due tomorrow!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadlines',
            'Deadline Reminders',
            channelDescription: 'Reminders for upcoming goal deadlines',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint('Failed to schedule deadline reminder: $e');
    }
  }

  /// Cancel all notifications for a goal (deadline + all its sessions)
  static Future<void> cancelGoalNotifications(
    String goalId,
    List<StudySession> sessions,
  ) async {
    try {
      await _plugin.cancel(goalId.hashCode);

      for (final session in sessions) {
        await _plugin.cancel(session.id.hashCode);
      }
    } catch (e) {
      debugPrint('Failed to cancel goal notifications: $e');
    }
  }

  /// Cancel a single session notification
  static Future<void> cancelSessionNotification(String sessionId) async {
    try {
      await _plugin.cancel(sessionId.hashCode);
    } catch (e) {
      debugPrint('Failed to cancel session notification: $e');
    }
  }
}
