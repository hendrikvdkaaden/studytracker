import 'settings_service.dart';

/// Decides when a streak is worth celebrating.
///
/// A pure decision kept apart from the dialog that shows it, for the same
/// reason [FreezeOutcome.worthReporting] is: reaching it through a pumped
/// widget would drag in Hive, Riverpod and a navigator for what is one
/// comparison.
class StreakCelebration {
  const StreakCelebration._();

  /// Whether [streak] is an increase over what the user has already been
  /// congratulated on.
  ///
  /// Strictly greater: the streak is recomputed on every rebuild, so an
  /// equal value means the same +1 coming round again, not a new one.
  static bool shouldCelebrate({
    required int streak,
    required int lastCelebrated,
  }) {
    return streak > lastCelebrated;
  }

  /// Reads the stored value, decides, and records the outcome.
  ///
  /// Returns the streak to celebrate, or null when there is nothing to show.
  ///
  /// The stored value becomes [streak] either way, so it follows the streak
  /// down as well as up. Keeping a high-water mark instead would mean a user
  /// who reaches 10, misses a day and drops to 1 sees nothing until they pass
  /// 10 again -- every increase in between silently swallowed.
  ///
  /// Written before the dialog opens, not after: if the app dies while the
  /// dialog is up the celebration is lost once, which is far better than it
  /// reappearing on every launch.
  ///
  /// Call this from anywhere a session can be completed. Today that is only
  /// the study timer, because it is the only thing that sets `isCompleted`,
  /// but the coupling is worth stating: a second completion path that skipped
  /// this would not just miss its own celebration -- the stored value would
  /// drift up with the streak and swallow the next legitimate one too.
  static Future<int?> evaluate(int streak) async {
    final last = SettingsService.lastCelebratedStreak;
    final celebrate = shouldCelebrate(streak: streak, lastCelebrated: last);

    if (streak != last) {
      await SettingsService.setLastCelebratedStreak(streak);
    }

    return celebrate ? streak : null;
  }
}
