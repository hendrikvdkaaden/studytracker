import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Reminders have both an OS permission and a stored preference. The flag is
/// what lets someone keep permission granted while turning reminders off --
/// without it the Profile switch could never be switched off, since the app
/// cannot revoke an OS permission.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notif_flag');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('a fresh install has reminders off', () {
    expect(SettingsService.notificationsEnabled, isFalse);
  });

  test('never written is distinguishable from written false', () async {
    // The migration for upgrading users hangs on this: it seeds the flag from
    // the OS exactly once. If "never chosen" read the same as "chosen no", it
    // would switch reminders back on for someone who turned them off.
    expect(SettingsService.notificationsEnabledIsUnset, isTrue);

    await SettingsService.setNotificationsEnabled(false);

    expect(SettingsService.notificationsEnabledIsUnset, isFalse);
    expect(SettingsService.notificationsEnabled, isFalse);
  });

  test('the choice survives a restart', () async {
    await SettingsService.setNotificationsEnabled(true);

    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox('settings');

    expect(SettingsService.notificationsEnabled, isTrue);
    expect(SettingsService.notificationsEnabledIsUnset, isFalse);
  });

  test('turning reminders back off is remembered', () async {
    await SettingsService.setNotificationsEnabled(true);
    await SettingsService.setNotificationsEnabled(false);

    expect(SettingsService.notificationsEnabled, isFalse);
  });
}
