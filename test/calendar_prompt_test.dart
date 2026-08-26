import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Users who onboarded before calendar sync existed get offered it once on
/// launch. Getting "once" wrong is the whole risk here: asking every launch
/// is nagging, never asking means the feature stays invisible to them.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('calendar_prompt_test');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('is owed to a user upgrading from a version without sync', () {
    expect(SettingsService.calendarPromptShown, isFalse);
    expect(SettingsService.shouldOfferCalendarSync, isTrue);
  });

  test('is not repeated once it has been shown', () async {
    await SettingsService.setCalendarPromptShown(true);

    expect(
      SettingsService.shouldOfferCalendarSync,
      isFalse,
      reason: 'declining once must not bring it back every launch',
    );
  });

  test('is skipped when sync is already on', () async {
    await SettingsService.setCalendarSyncEnabled(true);

    expect(
      SettingsService.shouldOfferCalendarSync,
      isFalse,
      reason: 'there is nothing left to offer',
    );
  });

  test('stays skipped after the user turns sync back off', () async {
    // Someone who connected and later switched it off in Profile made a
    // deliberate choice; the launch prompt must not second-guess it.
    await SettingsService.setCalendarPromptShown(true);
    await SettingsService.setCalendarSyncEnabled(true);
    await SettingsService.setCalendarSyncEnabled(false);

    expect(SettingsService.shouldOfferCalendarSync, isFalse);
  });

  test('a new user who finished onboarding is never asked', () async {
    // Onboarding has its own calendar step, so completing it marks the
    // prompt as shown.
    await SettingsService.setOnboardingCompleted(true);
    await SettingsService.setCalendarPromptShown(true);

    expect(SettingsService.shouldOfferCalendarSync, isFalse);
  });
}
