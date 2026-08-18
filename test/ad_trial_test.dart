import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// The daily allowance for the ad-backed auto plan trial. Only the date logic
/// is covered here — the AdMob SDK itself is verified by hand.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ad_trial_test');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('canUseAdTrialToday', () {
    test('is allowed when the trial has never been used', () {
      expect(SettingsService.lastAdTrialDate, isNull);
      expect(SettingsService.canUseAdTrialToday, isTrue);
    });

    test('is blocked after using it today', () async {
      await SettingsService.setLastAdTrialDate(DateTime.now());

      expect(SettingsService.canUseAdTrialToday, isFalse);
    });

    test('is allowed again the day after it was used', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await SettingsService.setLastAdTrialDate(yesterday);

      expect(SettingsService.canUseAdTrialToday, isTrue);
    });

    test('resets at midnight rather than 24 hours later', () async {
      // Used late yesterday evening: less than 24 hours ago, but a different
      // calendar day, so the allowance is back.
      final now = DateTime.now();
      final lateYesterday =
          DateTime(now.year, now.month, now.day - 1, 23, 30);
      await SettingsService.setLastAdTrialDate(lateYesterday);

      expect(SettingsService.canUseAdTrialToday, isTrue);
    });

    test('round-trips the stored date', () async {
      final when = DateTime(2026, 8, 12, 14, 30);
      await SettingsService.setLastAdTrialDate(when);

      expect(SettingsService.lastAdTrialDate, when);
    });
  });
}
