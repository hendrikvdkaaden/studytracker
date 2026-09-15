import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:deadly/services/streak_celebration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// When a streak increase is worth a dialog.
///
/// The rule this suite exists to protect: the streak is recomputed on every
/// rebuild, so "it went up" can only be answered against a record of what was
/// already celebrated. Without that, the same +1 would be celebrated again on
/// the next build.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('streak_celebration');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('the decision', () {
    test('a higher streak is worth celebrating', () {
      expect(
        StreakCelebration.shouldCelebrate(streak: 5, lastCelebrated: 4),
        isTrue,
      );
    });

    test('the same streak is not', () {
      // The recompute-on-every-rebuild case. Equal means the same increment
      // coming round again, not a new one.
      expect(
        StreakCelebration.shouldCelebrate(streak: 5, lastCelebrated: 5),
        isFalse,
      );
    });

    test('a dropped streak is not', () {
      expect(
        StreakCelebration.shouldCelebrate(streak: 1, lastCelebrated: 9),
        isFalse,
      );
    });

    test('a first streak beats the default of zero', () {
      expect(
        StreakCelebration.shouldCelebrate(streak: 1, lastCelebrated: 0),
        isTrue,
      );
    });

    test('no streak at all is not celebrated', () {
      expect(
        StreakCelebration.shouldCelebrate(streak: 0, lastCelebrated: 0),
        isFalse,
      );
    });
  });

  group('evaluating against storage', () {
    test('a fresh user celebrating day one', () async {
      expect(await StreakCelebration.evaluate(1), 1);
      expect(SettingsService.lastCelebratedStreak, 1);
    });

    test('evaluating twice celebrates once', () async {
      // The reason the value is stored at all.
      expect(await StreakCelebration.evaluate(3), 3);
      expect(await StreakCelebration.evaluate(3), isNull);
    });

    test('the next increment celebrates again', () async {
      await StreakCelebration.evaluate(3);

      expect(await StreakCelebration.evaluate(4), 4);
      expect(SettingsService.lastCelebratedStreak, 4);
    });

    test('a broken streak lowers the stored value without celebrating',
        () async {
      // Keeping a high-water mark here would swallow every increase until the
      // user climbed back past 10.
      await StreakCelebration.evaluate(10);

      expect(await StreakCelebration.evaluate(1), isNull);
      expect(SettingsService.lastCelebratedStreak, 1);
    });

    test('and then climbing again celebrates from the lower mark', () async {
      await StreakCelebration.evaluate(10);
      await StreakCelebration.evaluate(1);

      expect(
        await StreakCelebration.evaluate(2),
        2,
        reason: 'a rebuilt streak must be celebrated on its own terms',
      );
    });

    test('the record survives a restart', () async {
      await StreakCelebration.evaluate(6);

      await Hive.close();
      Hive.init(tempDir.path);
      await Hive.openBox('settings');

      expect(SettingsService.lastCelebratedStreak, 6);
      expect(
        await StreakCelebration.evaluate(6),
        isNull,
        reason: 'reopening the app must not re-celebrate',
      );
    });
  });
}
