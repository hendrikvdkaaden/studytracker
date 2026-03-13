import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// The default color palette used both when picking a new subject color
/// and when migrating legacy plain-string subjects.
const kDefaultSubjectColors = [
  Color(0xFF4B6BFB),
  Color(0xFFE8445A),
  Color(0xFF2DC08E),
  Color(0xFFF5A623),
  Color(0xFFA855F7),
  Color(0xFFF0527A),
];

class SubjectData {
  final String name;
  final Color color;

  const SubjectData({required this.name, required this.color});

  Map<String, dynamic> toMap() => {
        'name': name,
        'color': color.toARGB32(),
      };

  factory SubjectData.fromMap(Map<String, dynamic> map) => SubjectData(
        name: map['name'] as String,
        color: Color(map['color'] as int),
      );

  @override
  bool operator ==(Object other) =>
      other is SubjectData && other.name == name && other.color == color;

  @override
  int get hashCode => Object.hash(name, color);
}


class SettingsService {
  static const String _boxName = 'settings';

  // In-memory cache — invalidated on every write
  static List<SubjectData>? _subjectDataCache;

  static const String _keyUserName = 'userName';
  static const String _keySessionReminderMinutes = 'sessionReminderMinutes';
  static const String _keyDeadlineReminderDays = 'deadlineReminderDays';
  static const String _keyThemeMode = 'themeMode';
  static const String _keySubjects = 'subjects';
  static const String _keySubjectData = 'subjectData';
  static const String _keySchoolName = 'schoolName';

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

  // Subject data (name + color)
  static List<SubjectData> get subjectData {
    if (_subjectDataCache != null) return _subjectDataCache!;

    final raw = _box.get(_keySubjectData);
    if (raw != null) {
      _subjectDataCache = (raw as List)
          .map((e) => SubjectData.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      return _subjectDataCache!;
    }
    // Migrate from legacy plain-string subjects
    final legacy = _box.get(_keySubjects);
    if (legacy != null) {
      final legacyList = List<String>.from(legacy as List);
      _subjectDataCache = legacyList.asMap().entries.map((e) {
        return SubjectData(
          name: e.value,
          color: kDefaultSubjectColors[e.key % kDefaultSubjectColors.length],
        );
      }).toList();
      return _subjectDataCache!;
    }
    _subjectDataCache = [];
    return _subjectDataCache!;
  }

  static Future<void> setSubjectData(List<SubjectData> data) async {
    _subjectDataCache = null;
    await _box.put(_keySubjectData, data.map((s) => s.toMap()).toList());
  }

  // Backward-compatible subjects getter
  static List<String> get subjects => subjectData.map((s) => s.name).toList();

  static Future<void> setSubjects(List<String> subjects) async {
    await _box.put(_keySubjects, subjects);
  }

  static Color? colorForSubject(String name) {
    final data = subjectData;
    for (final s in data) {
      if (s.name == name) return s.color;
    }
    return null;
  }

  // School name
  static String get schoolName =>
      _box.get(_keySchoolName, defaultValue: '') as String;

  static Future<void> setSchoolName(String name) async {
    await _box.put(_keySchoolName, name);
  }
}
