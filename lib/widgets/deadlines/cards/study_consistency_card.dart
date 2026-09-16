import 'package:flutter/material.dart';
import '../../../models/day_status.dart';
import '../../../theme/app_theme_extension.dart';
import '../../common/streak_badge.dart';
import '../../../utils/l10n_extension.dart';
import 'day_status_circle.dart';

class StudyConsistencyCard extends StatelessWidget {
  final Map<int, DayStatus> weeklyConsistency; // weekday (1-7) -> status
  final int missedSessionsCount;
  final int studyStreak;

  const StudyConsistencyCard({
    super.key,
    required this.weeklyConsistency,
    required this.missedSessionsCount,
    required this.studyStreak,
  });

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  bool get _hasAnySessions => weeklyConsistency.values.any(
        (s) =>
            s == DayStatus.completed ||
            s == DayStatus.missed ||
            // A frozen day had a session too. Leaving it out made a week
            // rescued entirely by freezes report "no sessions" directly above
            // its own snowflakes.
            s == DayStatus.frozen,
      );

  int get _completedDaysCount =>
      weeklyConsistency.values.where((s) => s == DayStatus.completed).length;

  ({String title, String subtitle}) _buildStatusText(BuildContext context) {
    final l10n = context.l10n;
    if (!_hasAnySessions) {
      return (
        title: l10n.consistencyNoSessionsTitle,
        subtitle: l10n.consistencyNoSessionsSubtitle,
      );
    }
    if (missedSessionsCount > 0) {
      return (
        title: l10n.consistencyMissedTitle(missedSessionsCount),
        subtitle: l10n.consistencyMissedSubtitle,
      );
    }
    final days = _completedDaysCount;
    return (
      title: l10n.consistencyDaysNoMissed(days),
      subtitle: l10n.consistencyDaysNoMissedSubtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _buildStatusText(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.statCardBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF6750A4).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.event_busy, color: Colors.amber.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.consistencyTitle,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: context.colors.badgeAmber,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  // In the header row rather than floating over the card, so
                  // it lines up with the title instead of approximately so.
                  // Shared with the home screen so the two cannot drift on
                  // threshold, colour or size. Hides itself at zero.
                  StreakBadge(streak: studyStreak, size: 16),
                ],
              ),
              const SizedBox(height: 12),

              // Status text
              Text(
                status.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Days grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final weekday = index + 1;
                  final dayStatus =
                      weeklyConsistency[weekday] ?? DayStatus.notPlanned;
                  return Column(
                    children: [
                      Text(
                        _dayLabels[index],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DayStatusCircle(status: dayStatus),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
