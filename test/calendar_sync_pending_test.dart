import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Calendar sync has both an OS permission and a stored preference, and the
/// app cannot revoke the permission. So a granted permission says nothing
/// about whether sync is wanted: everyone who ever turned sync off still has
/// one. The pending flag records that the user was actually sent to settings,
/// which is what keeps a resume from reading that standing grant as consent
/// and switching sync back on by itself.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('calendar_pending');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('nothing is pending on a fresh install', () {
    expect(SettingsService.calendarSyncPending, isFalse);
  });

  test('being sent to settings is what marks a trip pending', () async {
    await SettingsService.setCalendarSyncPending(true);
    expect(SettingsService.calendarSyncPending, isTrue);
  });

  test('a finished trip does not stay pending', () async {
    // Cleared as soon as the resume acts on it. Left set, every later resume
    // would re-enable sync and backfill the calendar again.
    await SettingsService.setCalendarSyncPending(true);
    await SettingsService.setCalendarSyncPending(false);

    expect(SettingsService.calendarSyncPending, isFalse);
  });

  test('turning sync off abandons an outstanding trip', () async {
    // The user asked to be sent to settings, never granted anything, then
    // turned sync off. A stale pending flag would let a later resume enable
    // sync against that decision.
    await SettingsService.setCalendarSyncPending(true);

    await SettingsService.setCalendarSyncEnabled(false);
    await SettingsService.setCalendarSyncPending(false);

    expect(SettingsService.calendarSyncPending, isFalse);
    expect(SettingsService.calendarSyncEnabled, isFalse);
  });
}
