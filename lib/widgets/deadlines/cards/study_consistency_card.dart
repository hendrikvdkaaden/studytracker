import 'package:flutter/material.dart';
import '../../../models/day_status.dart';
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
        (s) => s == DayStatus.completed || s == DayStatus.missed,
      );

  int get _completedDaysCount =>
      weeklyConsistency.values.where((s) => s == DayStatus.completed).length;

  ({String title, String subtitle}) get _statusText {
    if (!_hasAnySessions) {
      return (
        title: 'Start Your Week Strong',
        subtitle: 'Plan some study sessions to track your week.',
      );
    }
    if (missedSessionsCount > 0) {
      return (
        title:
            '$missedSessionsCount Session${missedSessionsCount != 1 ? 's' : ''} Missed',
        subtitle: "Don't give up! You can still crush this week.",
      );
    }
    final days = _completedDaysCount;
    return (
      title: '$days Day${days != 1 ? 's' : ''} No Session Missed',
      subtitle: 'Great job! Keep up the consistency.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = _statusText;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2b2930) : const Color(0xFFF3EDF7),
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
                  Text(
                    'STUDY CONSISTENCY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.amber.shade400 : Colors.amber.shade700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status text
              Text(
                status.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1d1b20),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
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
                          color: Colors.grey.shade400,
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

          // Streak badge — top right
          if (studyStreak >= 2)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '$studyStreak',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
