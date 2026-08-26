import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// "Later" has to hold until the next release. Getting this wrong turns a
/// helpful reminder into a dialog on every single launch.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('update_prompt_test');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('a version nobody dismissed is worth prompting for', () {
    expect(SettingsService.updateSnoozedVersion, isNull);
    expect(SettingsService.shouldPromptForUpdate('1.2.0'), isTrue);
  });

  test('dismissing holds for that version', () async {
    await SettingsService.setUpdateSnoozedVersion('1.2.0');

    expect(
      SettingsService.shouldPromptForUpdate('1.2.0'),
      isFalse,
      reason: 'Later must not reappear on the next launch',
    );
  });

  test('a later release asks again', () async {
    await SettingsService.setUpdateSnoozedVersion('1.2.0');

    expect(
      SettingsService.shouldPromptForUpdate('1.3.0'),
      isTrue,
      reason: 'dismissing one version must not silence every future one',
    );
  });

  // checkForUpdate records the timestamp in a finally, so a lookup that keeps
  // failing still engages the interval. Without that, a bundle id not yet on
  // the store answers with an empty list forever and the check hits the
  // network on every single launch.
  group('check interval', () {
    test('has never run on a fresh install', () {
      expect(SettingsService.lastUpdateCheck, isNull);
    });

    test('round-trips through storage', () async {
      final when = DateTime(2026, 8, 26, 14, 30);
      await SettingsService.setLastUpdateCheck(when);

      expect(SettingsService.lastUpdateCheck, when);
    });
  });
}
