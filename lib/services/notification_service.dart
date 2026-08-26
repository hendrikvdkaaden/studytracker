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

  /// Prefix marking a payload as pointing at a study session.
  static const String _sessionPrefix = 'session:';

  /// Payload that sends a tap to the timer for [sessionId].
  static String sessionPayload(String sessionId) =>
      '$_sessionPrefix$sessionId';

  /// The session id in [payload], or null when it points at something else.
  static String? sessionIdFromPayload(String? payload) {
    if (payload == null || !payload.startsWith(_sessionPrefix)) return null;
    final id = payload.substring(_sessionPrefix.length);
    return id.isEmpty ? null : id;
  }

  /// Called with the session id when a reminder is tapped.
  static void Function(String sessionId)? onSessionTapped;

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _handleResponse,
      );
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  static void _handleResponse(NotificationResponse response) {
    final sessionId = sessionIdFromPayload(response.payload);
    if (sessionId == null) return;
    onSessionTapped?.call(sessionId);
  }

  /// The session whose reminder launched the app from a cold start, if any.
  ///
  /// A tap on a notification while the app is not running arrives before
  /// there is anything to navigate with, so it has to be asked for instead.
  static Future<String?> sessionIdFromLaunch() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return sessionIdFromPayload(details.notificationResponse?.payload);
    } catch (e) {
      debugPrint('Failed to read notification launch details: $e');
      return null;
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
  /// - If session has startTime: N min before startTime
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

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin.zonedSchedule(
        id: session.id.hashCode,
        title: 'Study session coming up',
        body: 'Time to study "$goalTitle" - ${session.formattedDuration}',
        scheduledDate: scheduledDate,
        payload: sessionPayload(session.id),
        notificationDetails: const NotificationDetails(
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

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      final daysLabel = daysBefore == 1 ? 'tomorrow' : 'in $daysBefore days';
      await _plugin.zonedSchedule(
        id: goal.id.hashCode,
        title: 'Deadline $daysLabel',
        body: '"${goal.title}" is due $daysLabel!',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
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
      await _plugin.cancel(id: goalId.hashCode);

      for (final session in sessions) {
        await _plugin.cancel(id: session.id.hashCode);
      }
    } catch (e) {
      debugPrint('Failed to cancel goal notifications: $e');
    }
  }

  /// Cancel a single session notification
  static Future<void> cancelSessionNotification(String sessionId) async {
    try {
      await _plugin.cancel(id: sessionId.hashCode);
    } catch (e) {
      debugPrint('Failed to cancel session notification: $e');
    }
  }

  /// Show an immediate notification to remind the user to finish their active session
  static Future<void> showResumeSessionNotification(
    String goalTitle,
    String sessionId,
  ) async {
    try {
      await _plugin.show(
        id: 'resume_session'.hashCode,
        title: 'Don\'t forget your study session! 📚',
        body: 'You\'re still studying "$goalTitle". Tap to continue.',
        payload: sessionPayload(sessionId),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'study_timer',
            'Study Timer',
            channelDescription:
                'Notifications for active study timer sessions',
            importance: Importance.high,
            priority: Priority.high,
            ongoing: false,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Failed to show resume session notification: $e');
    }
  }

  /// Cancel the resume session notification
  static Future<void> cancelResumeSessionNotification() async {
    try {
      await _plugin.cancel(id: 'resume_session'.hashCode);
    } catch (e) {
      debugPrint('Failed to cancel resume session notification: $e');
    }
  }
}
