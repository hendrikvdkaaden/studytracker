import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:deadly/models/goal.dart';
import 'package:deadly/models/study_session.dart';
import 'package:deadly/services/notification_service.dart';
import 'package:deadly/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Reminders are handed to the OS once, when a goal or session is saved, so
/// anything that invalidates that handover needs rebuilding from storage.
///
/// Only the preference guard is covered here: everything past it goes through
/// the platform plugin, which has no binding in a unit test. That guard is
/// the part worth pinning anyway -- it is what stops a reschedule from
/// bringing back reminders someone deliberately switched off.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notif_reschedule');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Goal goal({required String id, bool isCompleted = false}) => Goal(
        id: id,
        title: 'Goal $id',
        subject: 'Biology',
        date: DateTime.now().add(const Duration(days: 7)),
        type: GoalType.exam,
        isCompleted: isCompleted,
        studyTime: 120,
      );

  StudySession session({required String id, required String goalId}) =>
      StudySession(
        id: id,
        goalId: goalId,
        date: DateTime.now().add(const Duration(days: 1)),
        duration: 60,
      );

  /// Captures what the service logs. Every plugin call is wrapped in a
  /// try/catch that reports failures this way and swallows them, so with no
  /// platform binding the log is the only evidence of whether the plugin was
  /// reached at all.
  Future<List<String>> logsFrom(Future<void> Function() action) async {
    final logs = <String>[];
    final previous = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    try {
      await action();
    } finally {
      debugPrint = previous;
    }
    return logs;
  }

  test('does nothing while reminders are off', () async {
    await SettingsService.setNotificationsEnabled(false);

    final logs = await logsFrom(
      () => NotificationService.rescheduleAll(
        goals: [goal(id: 'g1')],
        sessions: [session(id: 's1', goalId: 'g1')],
      ),
    );

    // Silence means the guard returned before any plugin call. Drop the
    // guard and the cancel/schedule attempts log their failures here, which
    // is what makes this test able to catch its removal.
    expect(logs, isEmpty);
  });

  test('an empty library is not an error', () async {
    await SettingsService.setNotificationsEnabled(false);

    final logs = await logsFrom(
      () => NotificationService.rescheduleAll(goals: [], sessions: []),
    );

    expect(logs, isEmpty);
  });
}
