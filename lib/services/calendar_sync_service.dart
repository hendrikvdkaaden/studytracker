import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/foundation.dart';

import '../models/goal.dart';
import '../models/study_session.dart';
import 'calendar_event_mapper.dart';
import 'settings_service.dart';

/// Writes deadlines and study sessions to a calendar the app owns.
///
/// One-way only: the app never reads events back. Mirrors NotificationService
/// in posture — every method swallows its errors, because a calendar entry is
/// a convenience and must never break a user action.
///
/// Every sync method returns early when the user has sync switched off, so
/// call sites do not need their own guards.
class CalendarSyncService {
  static const String _calendarName = 'Deadly';

  /// How many events to write at once. Unbounded parallelism over hundreds of
  /// events can exhaust the platform channel on Android.
  static const int _batchSize = 10;

  static final DeviceCalendar _plugin = DeviceCalendar.instance;

  /// Resolved calendar id for this process, avoiding a lookup per event.
  static String? _cachedCalendarId;

  static bool get isEnabled => SettingsService.calendarSyncEnabled;

  /// Asks for calendar access. Only ever called from the settings toggle.
  static Future<bool> requestPermission() async {
    try {
      final status = await _plugin.requestPermissions();
      return status == CalendarPermissionStatus.granted;
    } catch (e) {
      debugPrint('Calendar permission request failed: $e');
      return false;
    }
  }

  /// Checks access without prompting, so the settings row can show the real
  /// state when the user revoked access in system settings.
  static Future<bool> hasPermission() async {
    try {
      final status = await _plugin.hasPermissions();
      return status == CalendarPermissionStatus.granted;
    } catch (e) {
      debugPrint('Calendar permission check failed: $e');
      return false;
    }
  }

  /// Sends the user to the system settings for this app.
  static Future<void> openSettings() async {
    try {
      await _plugin.openAppSettings();
    } catch (e) {
      debugPrint('Opening app settings failed: $e');
    }
  }

  /// Finds the app's calendar, creating it if needed.
  ///
  /// A stored id is verified against the device: the user may have deleted the
  /// calendar in their calendar app, in which case a fresh one is created.
  static Future<String?> _ensureCalendar() async {
    if (_cachedCalendarId != null) return _cachedCalendarId;

    try {
      final calendars = await _plugin.listCalendars();

      final storedId = SettingsService.calendarId;
      if (storedId != null && calendars.any((c) => c.id == storedId)) {
        _cachedCalendarId = storedId;
        return storedId;
      }

      // Match on name in case the calendar exists from an earlier install.
      for (final c in calendars) {
        if (c.name == _calendarName && !c.readOnly) {
          _cachedCalendarId = c.id;
          await SettingsService.setCalendarId(c.id);
          return c.id;
        }
      }

      final created = await _plugin.createCalendar(name: _calendarName);
      _cachedCalendarId = created;
      await SettingsService.setCalendarId(created);
      return created;
    } catch (e) {
      debugPrint('Resolving calendar failed: $e');
      return null;
    }
  }

  /// Creates the calendar so the toggle can report real success before any
  /// events exist.
  static Future<bool> prepareCalendar() async => await _ensureCalendar() != null;

  /// Writes a deadline as an all-day entry. Returns its event id, or null.
  static Future<String?> syncDeadline(Goal goal) async {
    if (!isEnabled) return null;
    final calendarId = await _ensureCalendar();
    if (calendarId == null) return null;

    try {
      return await _plugin.createEvent(
        calendarId: calendarId,
        title: CalendarEventMapper.deadlineTitle(goal),
        startDate: CalendarEventMapper.deadlineStart(goal),
        endDate: CalendarEventMapper.deadlineEnd(goal),
        isAllDay: true,
        description: goal.subject,
      );
    } catch (e) {
      debugPrint('Creating deadline event failed: $e');
      return null;
    }
  }

  /// Writes a study session as a timed block. Returns its event id, or null.
  static Future<String?> syncSession(
    StudySession session,
    String goalTitle,
    String subject,
  ) async {
    if (!isEnabled) return null;
    final calendarId = await _ensureCalendar();
    if (calendarId == null) return null;

    try {
      return await _plugin.createEvent(
        calendarId: calendarId,
        title: CalendarEventMapper.sessionTitle(goalTitle),
        startDate: CalendarEventMapper.sessionStart(session),
        endDate: CalendarEventMapper.sessionEnd(session),
        description: CalendarEventMapper.sessionDescription(
          subject,
          session.notes,
        ),
      );
    } catch (e) {
      debugPrint('Creating session event failed: $e');
      return null;
    }
  }

  /// Writes many sessions at once, returning session id -> event id.
  ///
  /// Used by the auto planner and by the initial fill when sync is switched
  /// on, where writing one at a time would leave the user waiting.
  static Future<Map<String, String>> syncSessions(
    List<StudySession> sessions,
    String goalTitle,
    String subject,
  ) async {
    final result = <String, String>{};
    if (!isEnabled || sessions.isEmpty) return result;
    if (await _ensureCalendar() == null) return result;

    for (var i = 0; i < sessions.length; i += _batchSize) {
      final batch = sessions.skip(i).take(_batchSize).toList();
      final ids = await Future.wait(
        batch.map((s) => syncSession(s, goalTitle, subject)),
      );
      for (var j = 0; j < batch.length; j++) {
        final id = ids[j];
        if (id != null) result[batch[j].id] = id;
      }
    }
    return result;
  }

  /// Removes a single event. Safe to call with null or an id that no longer
  /// exists.
  static Future<void> deleteEvent(String? eventId) async {
    if (eventId == null) return;
    try {
      await _plugin.deleteEvent(eventId: eventId);
    } catch (e) {
      debugPrint('Deleting calendar event failed: $e');
    }
  }

  static Future<void> deleteEvents(Iterable<String?> eventIds) async {
    for (final id in eventIds) {
      await deleteEvent(id);
    }
  }

  /// Deletes the whole calendar, removing every event the app created in one
  /// step. Used when the user switches sync off or wipes their data.
  static Future<void> purgeAll() async {
    final calendarId = _cachedCalendarId ?? SettingsService.calendarId;
    _cachedCalendarId = null;
    await SettingsService.setCalendarId(null);
    if (calendarId == null) return;

    try {
      await _plugin.deleteCalendar(calendarId);
    } catch (e) {
      debugPrint('Deleting calendar failed: $e');
    }
  }
}
