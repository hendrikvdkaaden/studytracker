import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:deadly/widgets/add_goal/pickers/auto_plan_wizard_modal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// The wizard only offers "plan around my calendar" to users who already
/// granted calendar access by switching sync on. Showing it otherwise would
/// put a permission request behind a feature toggle, which is what App Review
/// rejected a build for under 5.1.1(iv).
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('plan_around_cal');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('the remembered preference', () {
    test('is off for a new user', () {
      expect(SettingsService.planAroundCalendar, isFalse);
    });

    test('survives a restart once switched on', () async {
      await SettingsService.setPlanAroundCalendar(true);

      await Hive.close();
      Hive.init(tempDir.path);
      await Hive.openBox('settings');

      expect(
        SettingsService.planAroundCalendar,
        isTrue,
        reason: 'a full timetable does not change between plans',
      );
    });

    test('survives calendar sync being switched off', () async {
      // The row is hidden and busyBlocks returns nothing while sync is off,
      // so there is no reason to forget what the user asked for.
      await SettingsService.setPlanAroundCalendar(true);
      await SettingsService.setCalendarSyncEnabled(true);
      await SettingsService.setCalendarSyncEnabled(false);

      expect(SettingsService.planAroundCalendar, isTrue);
    });
  });

  group('the wizard result', () {
    test('defaults to leaving the calendar out of it', () {
      const result = AutoPlanWizardResult(
        totalMinutes: 240,
        weekdays: [1, 2, 3],
        startHour: 9,
        startMinute: 0,
        endHour: 17,
        endMinute: 0,
        sessionDuration: 60,
        breakMinutes: 15,
      );

      expect(
        result.avoidCalendarEvents,
        isFalse,
        reason: 'existing callers must not start reading the calendar',
      );
    });

    test('carries the choice when made', () {
      const result = AutoPlanWizardResult(
        totalMinutes: 240,
        weekdays: [1, 2, 3],
        startHour: 9,
        startMinute: 0,
        endHour: 17,
        endMinute: 0,
        sessionDuration: 60,
        breakMinutes: 15,
        avoidCalendarEvents: true,
      );

      expect(result.avoidCalendarEvents, isTrue);
    });
  });
}
