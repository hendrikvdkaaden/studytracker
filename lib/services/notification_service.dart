import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

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
      // All three default to true, and the native initialize goes straight on
      // to requestAuthorizationWithOptions -- which put the system prompt on
      // the splash screen, before the user had seen anything. Onboarding asks
      // for it now, with an explanation.
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      );
      const settings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _handleResponse,
      );

      await _seedEnabledFromSystem();
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

  /// Carries an existing grant over for users upgrading from a build that
  /// asked at startup.
  ///
  /// They already said yes and are getting reminders; a prompt or a dialog
  /// would be a regression for a permission they gave. Only ever runs while
  /// the preference has never been written, so someone who later turned
  /// reminders off is not switched back on.
  static Future<void> _seedEnabledFromSystem() async {
    if (!SettingsService.notificationsEnabledIsUnset) return;
    await SettingsService.setNotificationsEnabled(await hasPermission());
  }

  /// Asks the user for permission, prompting on both platforms.
  ///
  /// Only called from the onboarding step and the Profile switch, both of
  /// which explain the request first.
  static Future<bool> requestPermission() async {
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        // Every option defaults to false, so a bare call asks for nothing.
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      // Null means neither platform resolved, which is not a grant. The older
      // `?? true` here is what made an iOS refusal invisible.
      return granted ?? false;
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  /// Whether the system currently lets the app post notifications.
  ///
  /// A pure read: never prompts, so it is safe to call on every resume.
  static Future<bool> hasPermission() async {
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final options = await ios.checkPermissions();
        return options?.isEnabled ?? false;
      }

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    } catch (e) {
      debugPrint('Failed to check notification permission: $e');
      return false;
    }
  }

  /// Sends the user to the system settings for this app.
  ///
  /// iOS only. A refusal there is terminal -- the prompt never returns -- so
  /// settings is the only way back. Android re-prompts on its own, and
  /// `app-settings:` does nothing there. Unlike the calendar plugin, this one
  /// ships no settings opener, hence url_launcher.
  static Future<void> openSettings() async {
    if (!Platform.isIOS) return;
    try {
      await launchUrl(
        Uri.parse('app-settings:'),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Opening app settings failed: $e');
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
      if (!SettingsService.notificationsEnabled) return;

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
      if (!SettingsService.notificationsEnabled) return;

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

  /// Show an immediate notification to remind the user to finish their active
  /// session.
  ///
  /// Not gated on the reminders preference: this is the way back into a timer
  /// the user started and left running, not a reminder they opted into. Gating
  /// it would strand a running session behind a setting about deadlines.
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

  /// Drops every scheduled notification.
  ///
  /// Used when reminders are switched off: without it the ones already handed
  /// to the system keep firing for days afterwards, which reads as a bug.
  /// Deliberately unguarded -- cancelling has to work precisely when the
  /// preference says no.
  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Rebuilds every scheduled reminder from the stored goals and sessions.
  ///
  /// Reminders are handed to the OS once, when a goal or session is saved.
  /// Anything that invalidates that handover -- [cancelAll] on a disable, a
  /// revoked-then-restored system permission, a change to the reminder
  /// offsets -- leaves the app believing in reminders the system no longer
  /// holds. Without this, switching reminders off and back on silently
  /// stopped them for every goal that already existed.
  ///
  /// Cancels each reminder before rescheduling it so a changed offset moves
  /// the reminder rather than adding a second one, and skips completed goals
  /// and sessions, which have nothing left to remind about. A no-op while the
  /// preference is off, so callers do not have to check first.
  static Future<void> rescheduleAll({
    required List<Goal> goals,
    required List<StudySession> sessions,
  }) async {
    if (!SettingsService.notificationsEnabled) return;

    final sessionsByGoal = <String, List<StudySession>>{};
    for (final session in sessions) {
      if (session.isCompleted) continue;
      sessionsByGoal.putIfAbsent(session.goalId, () => []).add(session);
    }

    for (final goal in goals) {
      final goalSessions = sessionsByGoal[goal.id] ?? const <StudySession>[];
      // Cancels by the same ids the scheduling below reuses, so this clears
      // stale reminders without touching the resume notification a
      // backgrounded timer may be showing.
      await cancelGoalNotifications(goal.id, goalSessions);
      if (goal.isCompleted) continue;

      await scheduleDeadlineReminder(goal);
      for (final session in goalSessions) {
        await scheduleSessionReminder(session, goal.title);
      }
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
