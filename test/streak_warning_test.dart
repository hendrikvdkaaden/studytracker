import 'dart:io';

import 'package:deadly/models/study_session.dart';
import 'package:deadly/services/notification_service.dart';
import 'package:deadly/services/settings_service.dart';
import 'package:deadly/services/streak_freeze_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Whether the evening streak warning is warranted.
///
/// Scope, stated plainly: this covers
/// [NotificationService.shouldWarnAboutStreak] and nothing else. The
/// scheduling around it cannot be unit-tested at all --
/// flutter_local_notifications keeps a package-internal singleton that throws
/// LateInitializationError unless a real platform binding set it up, so the
/// call can only ever fail here. An earlier version of this file tested
/// `scheduleStreakWarning` directly and passed while asserting nothing: every
/// case came back false because the plugin threw, so deleting a guard changed
/// no result. Hence the split.
///
/// Still untested, and only verifiable on a device: that the notification is
/// scheduled for the right evening, carries the right text, and fires.
///
/// The decision is the part worth guarding. The warning claims a streak is at
/// stake tonight, and these are the rules that keep that claim true.
void main() {
  late Directory tempDir;

  final today = DateTime.now();

  StudySession session({required bool completed}) {
    final date = DateTime(today.year, today.month, today.day);
    return StudySession(
      id: 'today-$completed',
      goalId: 'goal-1',
      date: date,
      duration: 60,
      isCompleted: completed,
      completedAt: completed
          ? DateTime(date.year, date.month, date.day, 10)
          : null,
    );
  }

  bool shouldWarn({
    required List<StudySession> todaysSessions,
    required int streak,
  }) =>
      NotificationService.shouldWarnAboutStreak(
        todaysSessions: todaysSessions,
        streak: streak,
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('streak_warning');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('a streak with work still outstanding is worth warning about',
      () async {
    // The control for every negative case below: without one that comes back
    // true, those cannot tell a working rule from a broken one.
    await SettingsService.setNotificationsEnabled(true);

    expect(
      shouldWarn(todaysSessions: [session(completed: false)], streak: 5),
      isTrue,
    );
  });

  test('one unfinished session among several is enough', () async {
    await SettingsService.setNotificationsEnabled(true);

    expect(
      shouldWarn(
        todaysSessions: [
          session(completed: true),
          session(completed: false),
        ],
        streak: 5,
      ),
      isTrue,
    );
  });

  group('no warning when', () {
    test('reminders are switched off', () async {
      await SettingsService.setNotificationsEnabled(false);

      expect(
        shouldWarn(todaysSessions: [session(completed: false)], streak: 5),
        isFalse,
      );
    });

    test('there is no streak to lose', () async {
      await SettingsService.setNotificationsEnabled(true);

      expect(
        shouldWarn(todaysSessions: [session(completed: false)], streak: 0),
        isFalse,
      );
    });

    test('today holds no sessions at all', () async {
      // A day without planned sessions cannot break a streak -- the streak
      // scan skips it -- so warning about one would simply be untrue.
      await SettingsService.setNotificationsEnabled(true);

      expect(shouldWarn(todaysSessions: const [], streak: 5), isFalse);
    });

    test("today's sessions are already done", () async {
      await SettingsService.setNotificationsEnabled(true);

      expect(
        shouldWarn(todaysSessions: [session(completed: true)], streak: 5),
        isFalse,
      );
    });
  });

  test('the warning keeps one id, so it replaces rather than stacks', () {
    expect(
      NotificationService.streakWarningId,
      'streak_warning'.hashCode,
      reason: 'a fresh id per run would pile up warnings',
    );
  });

  group('what is worth telling the user', () {
    test('a rescue is reported', () {
      expect(
        FreezeOutcome.worthReporting(
          FreezeOutcome(
            daysFrozen: [DateTime(2026, 8, 9)],
            freezesEarned: 0,
            freezesAvailable: 1,
          ),
        ),
        isTrue,
      );
    });

    test('nothing at all is not', () {
      expect(FreezeOutcome.worthReporting(null), isFalse);
    });

    test('an earned freeze alone is not worth interrupting for', () {
      // Earning one is good news that can wait; a rescued streak is the only
      // thing the user has to be told, because it silently changed what they
      // would otherwise have seen.
      expect(
        FreezeOutcome.worthReporting(
          const FreezeOutcome(
            daysFrozen: [],
            freezesEarned: 1,
            freezesAvailable: 1,
          ),
        ),
        isFalse,
      );
    });
  });
}
