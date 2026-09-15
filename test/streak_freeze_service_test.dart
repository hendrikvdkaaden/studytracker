import 'dart:io';

import 'package:deadly/models/study_session.dart';
import 'package:deadly/services/settings_service.dart';
import 'package:deadly/services/streak_freeze_service.dart';
import 'package:deadly/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Earning and spending streak freezes.
///
/// The rule this suite exists to protect: spending is idempotent. The streak
/// itself is recalculated on every dashboard rebuild, so anything that spends a
/// token has to be safe to run repeatedly or the stock drains as the user
/// scrolls.
void main() {
  late Directory tempDir;

  final now = DateTime(2026, 8, 10, 14, 30);

  DateTime daysAgo(int n) =>
      DateTime(now.year, now.month, now.day - n);

  StudySession session({
    required int daysAgo,
    required bool completed,
    String suffix = '',
  }) {
    final date = DateTime(now.year, now.month, now.day - daysAgo);
    return StudySession(
      id: 'session-$daysAgo$suffix',
      goalId: 'goal-1',
      date: date,
      duration: 60,
      isCompleted: completed,
      completedAt: completed
          ? DateTime(date.year, date.month, date.day, 10)
          : null,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('streak_freeze');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('spending', () {
    test('a missed day costs one freeze and is recorded', () async {
      await SettingsService.setFreezesAvailable(1);

      final outcome = await StreakFreezeService.check(
        sessions: [
          session(daysAgo: 1, completed: false),
          session(daysAgo: 2, completed: true),
        ],
        now: now,
      );

      expect(outcome.savedStreak, isTrue);
      expect(outcome.daysFrozen, [daysAgo(1)]);
      expect(SettingsService.freezesAvailable, 0);
      expect(SettingsService.frozenDays, contains(daysAgo(1)));
    });

    test('running twice does not spend a second freeze', () async {
      // The reason this service exists apart from StreakService. A second run
      // must be a no-op, not another withdrawal.
      await SettingsService.setFreezesAvailable(2);
      final sessions = [
        session(daysAgo: 1, completed: false),
        session(daysAgo: 2, completed: true),
      ];

      await StreakFreezeService.check(sessions: sessions, now: now);
      final after = SettingsService.freezesAvailable;

      final second = await StreakFreezeService.check(
        sessions: sessions,
        now: now,
      );

      expect(second.daysFrozen, isEmpty);
      expect(SettingsService.freezesAvailable, after);
      expect(SettingsService.frozenDays.length, 1);
    });

    test('nothing is spent without a freeze in stock', () async {
      final outcome = await StreakFreezeService.check(
        sessions: [
          session(daysAgo: 1, completed: false),
          session(daysAgo: 2, completed: true),
        ],
        now: now,
      );

      expect(outcome.savedStreak, isFalse);
      expect(SettingsService.frozenDays, isEmpty);
    });

    test('a completed run spends nothing', () async {
      await SettingsService.setFreezesAvailable(2);

      final outcome = await StreakFreezeService.check(
        sessions: [
          session(daysAgo: 1, completed: true),
          session(daysAgo: 2, completed: true),
        ],
        now: now,
      );

      expect(outcome.daysFrozen, isEmpty);
      expect(SettingsService.freezesAvailable, 2);
    });

    test('today is never frozen while it is still running', () async {
      await SettingsService.setFreezesAvailable(2);

      await StreakFreezeService.check(
        sessions: [session(daysAgo: 0, completed: false)],
        now: now,
      );

      expect(SettingsService.frozenDays, isEmpty);
      expect(SettingsService.freezesAvailable, 2);
    });

    test('the rescued streak survives the gap', () async {
      await SettingsService.setFreezesAvailable(1);
      final sessions = [
        session(daysAgo: 0, completed: true),
        session(daysAgo: 1, completed: false),
        session(daysAgo: 2, completed: true),
        session(daysAgo: 3, completed: true),
      ];

      await StreakFreezeService.check(sessions: sessions, now: now);

      expect(
        StreakService.calculateStreak(
          sessions: sessions,
          now: now,
          frozenDays: SettingsService.frozenDays.toSet(),
        ),
        3,
        reason: 'three studied days bridged by one freeze',
      );
    });

    test('a gap too wide for the stock costs nothing', () async {
      // Two missed days in a row with one token. Covering the older day
      // leaves the newer one still breaking the chain, so the spend buys
      // nothing -- and the user would have been told their streak was saved
      // while the badge read zero.
      await SettingsService.setFreezesAvailable(1);

      final outcome = await StreakFreezeService.check(
        sessions: [
          session(daysAgo: 1, completed: false),
          session(daysAgo: 2, completed: false),
          session(daysAgo: 3, completed: true),
        ],
        now: now,
      );

      expect(outcome.daysFrozen, isEmpty);
      expect(outcome.savedStreak, isFalse);
      expect(outcome.freezesAvailable, 1, reason: 'the token is kept');
      expect(SettingsService.frozenDays, isEmpty);
    });

    test('a gap the stock can bridge is still covered', () async {
      // The counterpart: two missed days and two tokens does reconnect, so
      // the guard above must not block a spend that genuinely works.
      await SettingsService.setFreezesAvailable(2);

      final outcome = await StreakFreezeService.check(
        sessions: [
          session(daysAgo: 1, completed: false),
          session(daysAgo: 2, completed: false),
          session(daysAgo: 3, completed: true),
        ],
        now: now,
      );

      expect(outcome.daysFrozen, hasLength(2));
      expect(outcome.savedStreak, isTrue);
      expect(
        StreakService.calculateStreak(
          sessions: [
            session(daysAgo: 1, completed: false),
            session(daysAgo: 2, completed: false),
            session(daysAgo: 3, completed: true),
          ],
          now: now,
          frozenDays: SettingsService.frozenDays.toSet(),
        ),
        greaterThan(0),
      );
    });

  });

  group('earning', () {
    List<StudySession> streakOf(int days) => [
          for (var i = 0; i < days; i++)
            session(daysAgo: i, completed: true, suffix: 'a'),
        ];

    test('a short streak earns nothing', () async {
      await StreakFreezeService.check(sessions: streakOf(3), now: now);

      expect(SettingsService.freezesAvailable, 0);
    });

    test('seven days earns one', () async {
      final outcome = await StreakFreezeService.check(
        sessions: streakOf(7),
        now: now,
      );

      expect(outcome.freezesEarned, 1);
      expect(SettingsService.freezesAvailable, 1);
    });

    test('the same milestone does not pay twice', () async {
      final sessions = streakOf(7);

      await StreakFreezeService.check(sessions: sessions, now: now);
      final second = await StreakFreezeService.check(
        sessions: sessions,
        now: now,
      );

      expect(second.freezesEarned, 0);
      expect(SettingsService.freezesAvailable, 1);
    });

    test('the stock is capped at two', () async {
      // Literal 2, not StreakFreezeService.maxFreezes: an assertion written in
      // terms of the constant moves with it and holds at any value, so it
      // cannot detect the cap being raised.
      await SettingsService.setFreezesAvailable(2);

      final outcome = await StreakFreezeService.check(
        sessions: streakOf(21),
        now: now,
      );

      expect(outcome.freezesEarned, 0);
      expect(
        SettingsService.freezesAvailable,
        2,
        reason: 'banking forgiveness without limit makes the streak hollow',
      );
    });

    test('a full stock still earns once a freeze is spent', () async {
      // Guards the pairing of the two rules: the cap must limit hoarding, not
      // stop earning altogether once there is room again.
      await SettingsService.setFreezesAvailable(1);

      final outcome = await StreakFreezeService.check(
        sessions: streakOf(14),
        now: now,
      );

      expect(outcome.freezesEarned, 1);
      expect(SettingsService.freezesAvailable, 2);
    });

    test('a rebuilt streak earns again after a break', () async {
      // The mark records the milestone already paid for, so it has to fall
      // when the streak does. Kept as a high-water mark, someone who reached
      // 14 days and lost it would earn nothing at 7 on the way back up --
      // and nothing again until they passed 14.
      await SettingsService.setFreezeEarnedAtStreak(14);
      await SettingsService.setFreezesAvailable(0);

      final outcome = await StreakFreezeService.check(
        sessions: [
          for (var i = 1; i <= 7; i++) session(daysAgo: i, completed: true),
        ],
        now: now,
      );

      expect(outcome.freezesEarned, 1);
      expect(outcome.freezesAvailable, 1);
    });

    test('the rebuilt streak still does not pay twice', () async {
      // Lowering the mark must not reopen the farming hole the mark exists
      // to close: a second check at the same length earns nothing more.
      await SettingsService.setFreezeEarnedAtStreak(14);
      await SettingsService.setFreezesAvailable(0);

      final sessions = [
        for (var i = 1; i <= 7; i++) session(daysAgo: i, completed: true),
      ];

      await StreakFreezeService.check(sessions: sessions, now: now);
      final second = await StreakFreezeService.check(
        sessions: sessions,
        now: now,
      );

      expect(second.freezesEarned, 0);
      expect(second.freezesAvailable, 1);
    });

  });

  test('the record survives a restart', () async {
    await SettingsService.setFreezesAvailable(1);
    await StreakFreezeService.check(
      sessions: [
        session(daysAgo: 1, completed: false),
        session(daysAgo: 2, completed: true),
      ],
      now: now,
    );

    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox('settings');

    expect(SettingsService.frozenDays, contains(daysAgo(1)));
    expect(SettingsService.freezesAvailable, 0);
  });
}
