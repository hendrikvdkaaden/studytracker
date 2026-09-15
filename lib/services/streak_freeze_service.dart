import '../models/study_session.dart';
import 'settings_service.dart';
import 'streak_service.dart';

/// What a freeze check did, so the UI can tell the user about it.
class FreezeOutcome {
  /// Days newly covered by a freeze during this check.
  final List<DateTime> daysFrozen;

  /// Freezes handed out during this check.
  final int freezesEarned;

  /// Freezes left in stock afterwards.
  final int freezesAvailable;

  const FreezeOutcome({
    required this.daysFrozen,
    required this.freezesEarned,
    required this.freezesAvailable,
  });

  /// True when a streak was actually rescued, which is the only case worth
  /// interrupting the user for.
  bool get savedStreak => daysFrozen.isNotEmpty;

  /// Whether [outcome] is worth telling the user about.
  ///
  /// A predicate rather than a branch inside the widget: the rule about what
  /// is worth interrupting someone for is worth testing on its own, and
  /// reaching it through a pumped HomePage would drag in Hive, Riverpod, ads
  /// and subscriptions for a two-line decision.
  static bool worthReporting(FreezeOutcome? outcome) =>
      outcome != null && outcome.savedStreak;
}

/// Earns and spends streak freezes.
///
/// Split from [StreakService] on purpose. Calculating a streak happens on every
/// dashboard rebuild; spending a token must happen once. Putting the two
/// together would drain the stock as the user scrolls.
///
/// [now] is a parameter rather than a `DateTime.now()` call so this stays
/// testable on a fixed clock, matching [StreakService].
class StreakFreezeService {
  /// Streak days between freezes.
  static const int daysPerFreeze = 7;

  /// Most a user can hold. Without a ceiling a long streak would bank enough
  /// forgiveness to stop meaning anything.
  static const int maxFreezes = 2;

  /// Covers elapsed missed days with available freezes, then hands out any
  /// newly earned ones.
  ///
  /// Idempotent: a day already in [SettingsService.frozenDays] never costs a
  /// second token, so running this twice in a row is harmless.
  static Future<FreezeOutcome> check({
    required List<StudySession> sessions,
    required DateTime now,
  }) async {
    final storedFrozen = SettingsService.frozenDays.toSet();
    var available = SettingsService.freezesAvailable;

    final streakBefore = StreakService.calculateStreak(
      sessions: sessions,
      now: now,
      frozenDays: storedFrozen,
    );

    final alreadyFrozen = storedFrozen.toSet();
    final newlyFrozen = <DateTime>[];

    // Oldest first: a freeze is only worth spending on the day that would
    // break the chain earliest.
    for (final day in _missedDays(sessions: sessions, now: now).reversed) {
      if (available <= 0) break;
      if (alreadyFrozen.contains(day)) continue;

      alreadyFrozen.add(day);
      newlyFrozen.add(day);
      available--;
    }

    // Only keep the spend if it actually reconnected the chain. The scan
    // above hands back as many missed days as there are tokens, with no
    // regard for whether covering them reaches an unbroken run -- two missed
    // days and one freeze would otherwise burn the token on the older day,
    // leave the newer one breaking the streak anyway, and still report the
    // streak as saved.
    if (newlyFrozen.isNotEmpty) {
      final streakAfter = StreakService.calculateStreak(
        sessions: sessions,
        now: now,
        frozenDays: alreadyFrozen,
      );

      if (streakAfter <= streakBefore) {
        alreadyFrozen
          ..clear()
          ..addAll(storedFrozen);
        newlyFrozen.clear();
        available = SettingsService.freezesAvailable;
      }
    }

    if (newlyFrozen.isNotEmpty) {
      await SettingsService.setFrozenDays(alreadyFrozen.toList());
    }

    // Earn against the streak as it stands after any rescue, so a freeze that
    // just saved the chain counts toward the next one.
    final streak = StreakService.calculateStreak(
      sessions: sessions,
      now: now,
      frozenDays: alreadyFrozen,
    );

    // A broken streak drops the mark back down with it. Left as a permanent
    // high-water mark, someone who reached 70 days and lost it would have to
    // climb past 70 again before a rebuilt streak earned anything, so every
    // milestone on the way back up would pass unrewarded.
    //
    // It drops to the milestone *below* the current one, because the rule in
    // [_earn] is "strictly above the mark": parking it on the current
    // milestone would block the very streak that just reached it.
    final milestone = streak - (streak % daysPerFreeze);
    if (milestone < SettingsService.freezeEarnedAtStreak) {
      await SettingsService.setFreezeEarnedAtStreak(
        milestone - daysPerFreeze < 0 ? 0 : milestone - daysPerFreeze,
      );
    }

    final earned = _earn(streak: streak, available: available);
    available += earned;

    if (earned > 0) {
      await SettingsService.setFreezeEarnedAtStreak(milestone);
    }
    if (earned > 0 || newlyFrozen.isNotEmpty) {
      await SettingsService.setFreezesAvailable(available);
    }

    return FreezeOutcome(
      daysFrozen: newlyFrozen,
      freezesEarned: earned,
      freezesAvailable: available,
    );
  }

  /// How many freezes [streak] has earned that have not been handed out yet.
  static int _earn({required int streak, required int available}) {
    if (streak < daysPerFreeze) return 0;

    // Round down to the milestone this streak has reached. Comparing
    // milestones rather than raw lengths is what stops a streak parked at 7
    // from earning a fresh freeze on every check.
    final milestone = streak - (streak % daysPerFreeze);
    if (milestone <= SettingsService.freezeEarnedAtStreak) return 0;

    return available >= maxFreezes ? 0 : 1;
  }

  /// Elapsed days with unfinished sessions, newest first, capped at the
  /// number of freezes in stock.
  ///
  /// The cap is on count, not reachability: covering every day returned here
  /// may still leave the chain broken further back, so [check] verifies the
  /// spend against the resulting streak before keeping it.
  ///
  /// Mirrors [StreakService.calculateStreak]: days without sessions are
  /// skipped, and today never counts because its sessions may still be done.
  static List<DateTime> _missedDays({
    required List<StudySession> sessions,
    required DateTime now,
  }) {
    if (sessions.isEmpty) return const [];

    final today = DateTime(now.year, now.month, now.day);
    final earliest = DateTime(today.year, today.month, today.day - 364);

    final byDay = <DateTime, List<StudySession>>{};
    for (final s in sessions) {
      final day = DateTime(s.date.year, s.date.month, s.date.day);
      if (day.isBefore(earliest) || day.isAfter(today)) continue;
      byDay.putIfAbsent(day, () => []).add(s);
    }

    final frozen = SettingsService.frozenDays.toSet();
    final missed = <DateTime>[];

    // Skip i == 0: today is still in progress.
    for (var i = 1; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      final daySessions = byDay[day];

      if (daySessions == null || daySessions.isEmpty) continue;
      if (daySessions.every(StreakService.isCompletedOnTime)) continue;
      if (frozen.contains(day)) continue;

      missed.add(day);

      // Past the stock there is nothing left to spend, so older days cannot
      // be rescued either way.
      if (missed.length >= SettingsService.freezesAvailable) break;
    }

    return missed;
  }
}
