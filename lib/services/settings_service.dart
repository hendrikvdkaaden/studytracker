import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _boxName = 'settings';

  static const String _keyUserName = 'userName';
  static const String _keySessionReminderMinutes = 'sessionReminderMinutes';
  static const String _keyDeadlineReminderDays = 'deadlineReminderDays';
  static const String _keyThemeMode = 'themeMode';

  static Box get _box => Hive.box(_boxName);

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  // User name
  static String get userName => _box.get(_keyUserName, defaultValue: '') as String;

  static Future<void> setUserName(String name) async {
    await _box.put(_keyUserName, name);
  }

  // Session reminder (minutes before session)
  static int get sessionReminderMinutes =>
      _box.get(_keySessionReminderMinutes, defaultValue: 15) as int;

  static Future<void> setSessionReminderMinutes(int minutes) async {
    await _box.put(_keySessionReminderMinutes, minutes);
  }

  // Deadline reminder (days before deadline)
  static int get deadlineReminderDays =>
      _box.get(_keyDeadlineReminderDays, defaultValue: 1) as int;

  static Future<void> setDeadlineReminderDays(int days) async {
    await _box.put(_keyDeadlineReminderDays, days);
  }

  // Theme mode: 0 = system, 1 = light, 2 = dark
  static int get themeModeIndex =>
      _box.get(_keyThemeMode, defaultValue: 0) as int;

  static ThemeMode get themeMode {
    switch (themeModeIndex) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeModeIndex(int index) async {
    await _box.put(_keyThemeMode, index);
  }
}
