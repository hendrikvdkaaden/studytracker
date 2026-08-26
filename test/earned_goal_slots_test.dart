import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:deadly/services/subscription_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Watching an ad buys one more deadline. Unlike the auto-plan trial this has
/// to be a permanent count: the deadline it unlocks does not expire at
/// midnight, so a daily allowance would take back something already made.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('earned_slots');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('a new user gets the free limit and nothing more', () {
    expect(SettingsService.earnedGoalSlots, 0);
    expect(
      SubscriptionService.goalLimitWithEarned,
      SubscriptionService.freeGoalLimit,
    );
  });

  test('one ad buys exactly one deadline', () async {
    await SettingsService.addEarnedGoalSlot();

    expect(
      SubscriptionService.goalLimitWithEarned,
      SubscriptionService.freeGoalLimit + 1,
    );
  });

  test('slots accumulate', () async {
    await SettingsService.addEarnedGoalSlot();
    await SettingsService.addEarnedGoalSlot();
    await SettingsService.addEarnedGoalSlot();

    expect(SettingsService.earnedGoalSlots, 3);
    expect(
      SubscriptionService.goalLimitWithEarned,
      SubscriptionService.freeGoalLimit + 3,
    );
  });

  test('an earned slot survives a restart', () async {
    await SettingsService.addEarnedGoalSlot();

    // Reopening the box is what a relaunch does.
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox('settings');

    expect(
      SettingsService.earnedGoalSlots,
      1,
      reason: 'the deadline it bought is still there, so the slot must be too',
    );
  });

  test('does not touch the auto-plan allowance', () async {
    // The two rewards are separate: earning a deadline must not spend the
    // daily try at auto planning.
    await SettingsService.addEarnedGoalSlot();

    expect(SettingsService.canUseAdTrialToday, isTrue);
    expect(SettingsService.lastAdTrialDate, isNull);
  });
}
