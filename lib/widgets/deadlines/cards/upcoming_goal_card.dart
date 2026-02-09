import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../utils/goal_helpers.dart';
import '../../../utils/format_helpers.dart';

class UpcomingGoalCard extends StatelessWidget {
  final Goal goal;
  final int timeSpent; // in minutes
  final VoidCallback onTap;

  const UpcomingGoalCard({
    super.key,
    required this.goal,
    required this.timeSpent,
    required this.onTap,
  });

  int _getDaysLeft() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(goal.date.year, goal.date.month, goal.date.day);
    return deadline.difference(today).inDays;
  }

  double get _progressPercentage {
    if (goal.studyTime == 0) return 0;
    return (timeSpent / goal.studyTime).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = _getDaysLeft();
    final percentage = (_progressPercentage * 100).toInt();
    final iconColor = GoalHelpers.getGoalColor(goal.type);
    final formatTime = FormatHelpers.formatTime;
    final formatDate = FormatHelpers.formatDate;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1d1b20) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? iconColor.shade900.withOpacity(0.3)
                        : iconColor.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    GoalHelpers.getGoalIcon(goal.type),
                    color: iconColor.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        goal.subject.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isDark ? Colors.grey[500] : Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDate(goal.date),
                        style: TextStyle(
                          fontSize: 9,
                          color:
                              isDark ? Colors.grey[600] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: daysLeft <= 2
                        ? (isDark
                            ? Colors.orange.shade900.withOpacity(0.3)
                            : Colors.orange.shade50)
                        : (isDark
                            ? Colors.blue.shade900.withOpacity(0.3)
                            : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        daysLeft <= 2 ? Icons.timer : Icons.event,
                        size: 12,
                        color: daysLeft <= 2
                            ? Colors.orange.shade600
                            : Colors.blue.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${daysLeft}d',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: daysLeft <= 2
                              ? Colors.orange.shade600
                              : Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color:
                      isDark ? Colors.grey[800] : Colors.grey[100],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: constraints.maxWidth * _progressPercentage,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF0DF2DF),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatTime(timeSpent)} / ${formatTime(goal.studyTime)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0DF2DF),
                  ),
                ),
                Text(
                  '$percentage% Progress',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
