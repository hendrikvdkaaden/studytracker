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

  // Onboarding
  static const String _keyOnboardingCompleted = 'onboardingCompleted';

  static bool get onboardingCompleted =>
      _box.get(_keyOnboardingCompleted, defaultValue: false) as bool;

  static Future<void> setOnboardingCompleted(bool value) async {
    await _box.put(_keyOnboardingCompleted, value);
  }

  /// Whether the one-off calendar-sync offer has been shown.
  ///
  /// Users who onboarded before calendar sync existed never saw the step that
  /// offers it, so they get asked once on launch instead.
  static const String _keyCalendarPromptShown = 'calendarPromptShown';

  static bool get calendarPromptShown =>
      _box.get(_keyCalendarPromptShown, defaultValue: false) as bool;

  static Future<void> setCalendarPromptShown(bool value) async {
    await _box.put(_keyCalendarPromptShown, value);
  }

  /// Whether the one-off calendar offer is still owed to this user.
  ///
  /// False once it has been shown, and false when sync is already on — there
  /// is nothing left to offer. New users are excluded because onboarding
  /// marks the prompt as shown when it finishes.
  static bool get shouldOfferCalendarSync =>
      !calendarPromptShown && !calendarSyncEnabled;

  /// Whether the completed section on the dashboard is collapsed.
  ///
  /// Kept across launches: someone who hides their finished deadlines does
  /// not want them back on the next start.
  static const String _keyCompletedCollapsed = 'completedCollapsed';

  static bool get completedCollapsed =>
      _box.get(_keyCompletedCollapsed, defaultValue: false) as bool;

  static Future<void> setCompletedCollapsed(bool value) async {
    await _box.put(_keyCompletedCollapsed, value);
  }

  // Update check
  static const String _keyLastUpdateCheck = 'lastUpdateCheck';
  static const String _keyUpdateSnoozedVersion = 'updateSnoozedVersion';

  /// When the store was last asked about a newer release.
  static DateTime? get lastUpdateCheck {
    final raw = _box.get(_keyLastUpdateCheck);
    if (raw is! String) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> setLastUpdateCheck(DateTime value) async {
    await _box.put(_keyLastUpdateCheck, value.toIso8601String());
  }

  /// The store version the user last dismissed with "Later".
  ///
  /// Stored per version, so dismissing 1.2.0 stays dismissed but 1.3.0 asks
  /// again — the prompt is a reminder, not a nag.
  static String? get updateSnoozedVersion =>
      _box.get(_keyUpdateSnoozedVersion) as String?;

  static Future<void> setUpdateSnoozedVersion(String version) async {
    await _box.put(_keyUpdateSnoozedVersion, version);
  }

  /// Whether the user should be told about [version].
  static bool shouldPromptForUpdate(String version) =>
      updateSnoozedVersion != version;

  // Rewarded-ad trial for auto planning
  static const String _keyLastAdTrialDate = 'lastAdTrialDate';

  /// The day the user last unlocked auto planning by watching an ad, or null.
  static DateTime? get lastAdTrialDate {
    final raw = _box.get(_keyLastAdTrialDate);
    if (raw is! String) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> setLastAdTrialDate(DateTime value) async {
    await _box.put(_keyLastAdTrialDate, value.toIso8601String());
  }

  /// Whether the auto planner should avoid times the user is already busy.
  ///
  /// Remembered because the reason for wanting it -- a full timetable -- does
  /// not change between plans.
  static const String _keyPlanAroundCalendar = 'planAroundCalendar';

  static bool get planAroundCalendar =>
      _box.get(_keyPlanAroundCalendar, defaultValue: false) as bool;

  static Future<void> setPlanAroundCalendar(bool value) async {
    await _box.put(_keyPlanAroundCalendar, value);
  }

  // Rewarded-ad slots for extra deadlines
  static const String _keyEarnedGoalSlots = 'earnedGoalSlots';

  /// Extra deadlines unlocked by watching ads, on top of the free limit.
  ///
  /// A count rather than a daily allowance like [lastAdTrialDate]: a deadline
  /// sticks around, so an ad has to buy one slot permanently instead of
  /// re-unlocking the same one every day.
  static int get earnedGoalSlots =>
      _box.get(_keyEarnedGoalSlots, defaultValue: 0) as int;

  static Future<void> addEarnedGoalSlot() async {
    await _box.put(_keyEarnedGoalSlots, earnedGoalSlots + 1);
  }

  // Accent colour
  static const String _keyAccentPalette = 'accentPalette';

  /// Index into `AccentPalette.all`.
  ///
  /// Stored as an index to match the themeMode convention, which makes the
  /// order append-only: reordering the palettes would silently change what
  /// everyone already picked. New colours go on the end.
  static int get accentPaletteIndex =>
      _box.get(_keyAccentPalette, defaultValue: 0) as int;

  static Future<void> setAccentPaletteIndex(int index) async {
    await _box.put(_keyAccentPalette, index);
  }

  // Reminders
  static const String _keyNotificationsEnabled = 'notificationsEnabled';

  /// Whether the user wants reminders at all.
  ///
  /// Kept alongside the OS permission rather than derived from it: permission
  /// is the precondition, this is the preference. Without it the Profile
  /// switch could not be turned off, since switching off would mean revoking
  /// an OS permission the app cannot revoke, and the row would spring back on.
  static bool get notificationsEnabled =>
      _box.get(_keyNotificationsEnabled, defaultValue: false) as bool;

  static Future<void> setNotificationsEnabled(bool value) async {
    await _box.put(_keyNotificationsEnabled, value);
  }

  /// Whether the preference has never been written.
  ///
  /// Distinct from reading false: users upgrading from a build that asked for
  /// permission at startup are seeded from the OS once, and only once. A
  /// defaultValue read cannot tell "never chosen" from "chosen no", and would
  /// switch reminders back on for someone who deliberately turned them off.
  static bool get notificationsEnabledIsUnset =>
      _box.get(_keyNotificationsEnabled) == null;

  // Calendar sync
  static const String _keyCalendarSyncEnabled = 'calendarSyncEnabled';
  static const String _keyCalendarId = 'calendarId';
  static const String _keyCalendarSyncPending = 'calendarSyncPending';

  static bool get calendarSyncEnabled =>
      _box.get(_keyCalendarSyncEnabled, defaultValue: false) as bool;

  static Future<void> setCalendarSyncEnabled(bool value) async {
    await _box.put(_keyCalendarSyncEnabled, value);
  }

  /// True while the user has been sent to system settings to grant calendar
  /// access and has not come back yet.
  ///
  /// The app cannot revoke the OS grant, so a granted permission says nothing
  /// about whether sync is wanted -- someone who deliberately switched sync
  /// off still has it. Without this one-shot flag, resuming would read that
  /// standing grant as consent and turn sync back on every time.
  static bool get calendarSyncPending =>
      _box.get(_keyCalendarSyncPending, defaultValue: false) as bool;

  static Future<void> setCalendarSyncPending(bool value) async {
    await _box.put(_keyCalendarSyncPending, value);
  }

  /// Identifier of the app's own calendar on the device, once created.
  static String? get calendarId => _box.get(_keyCalendarId) as String?;

  static Future<void> setCalendarId(String? value) async {
    if (value == null) {
      await _box.delete(_keyCalendarId);
    } else {
      await _box.put(_keyCalendarId, value);
    }
  }

  // Streak freezes
  static const String _keyFreezesAvailable = 'freezesAvailable';
  static const String _keyFrozenDays = 'frozenDays';
  static const String _keyFreezeEarnedAtStreak = 'freezeEarnedAtStreak';

  /// Unspent freezes, each of which covers one missed day.
  ///
  /// A count like [earnedGoalSlots] rather than a daily allowance: a freeze is
  /// earned by keeping a streak up, then kept until a missed day spends it.
  static int get freezesAvailable =>
      _box.get(_keyFreezesAvailable, defaultValue: 0) as int;

  static Future<void> setFreezesAvailable(int value) async {
    await _box.put(_keyFreezesAvailable, value);
  }

  /// The days a freeze has already been spent on, as ISO-8601 dates.
  ///
  /// Stored rather than recomputed because it is what makes spending
  /// idempotent: a day already in this list never costs a second token, no
  /// matter how often the check runs. StreakService reads it; only
  /// StreakFreezeService writes it.
  static List<DateTime> get frozenDays {
    final raw = _box.get(_keyFrozenDays);
    if (raw is! List) return const [];
    final out = <DateTime>[];
    for (final entry in raw) {
      if (entry is! String) continue;
      final parsed = DateTime.tryParse(entry);
      // Normalised to midnight: StreakService compares against whole days.
      if (parsed != null) {
        out.add(DateTime(parsed.year, parsed.month, parsed.day));
      }
    }
    return out;
  }

  static Future<void> setFrozenDays(List<DateTime> days) async {
    // Keep only the last year. The streak scan looks no further back, so
    // without this the list would grow without limit.
    final cutoff = DateTime.now().subtract(const Duration(days: 365));
    final kept = days.where((d) => !d.isBefore(cutoff)).toList()..sort();
    await _box.put(
      _keyFrozenDays,
      [for (final d in kept) DateTime(d.year, d.month, d.day).toIso8601String()],
    );
  }

  /// The streak length the most recent freeze was handed out at.
  ///
  /// Without this a streak sitting at 7 would earn a fresh freeze on every
  /// check instead of once.
  static int get freezeEarnedAtStreak =>
      _box.get(_keyFreezeEarnedAtStreak, defaultValue: 0) as int;

  static Future<void> setFreezeEarnedAtStreak(int value) async {
    await _box.put(_keyFreezeEarnedAtStreak, value);
  }

  // Streak celebration
  static const String _keyLastCelebratedStreak = 'lastCelebratedStreak';

  /// The streak length the user was last congratulated on.
  ///
  /// Stored rather than derived because the streak is recomputed on every
  /// rebuild: without a record of what has already been celebrated, the same
  /// +1 would be celebrated again on the next build, and a celebration missed
  /// because the app closed would be lost for good.
  ///
  /// Follows the streak down as well as up -- see
  /// StreakCelebration.shouldCelebrate for why.
  static int get lastCelebratedStreak =>
      _box.get(_keyLastCelebratedStreak, defaultValue: 0) as int;

  static Future<void> setLastCelebratedStreak(int value) async {
    await _box.put(_keyLastCelebratedStreak, value);
  }

  /// True when the free ad-backed try has not been used today. The allowance
  /// resets at midnight rather than 24 hours after the last use.
  static bool get canUseAdTrialToday {
    final last = lastAdTrialDate;
    if (last == null) return true;
    final now = DateTime.now();
    return !(last.year == now.year &&
        last.month == now.month &&
        last.day == now.day);
  }
}
