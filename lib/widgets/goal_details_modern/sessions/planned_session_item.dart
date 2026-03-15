import 'package:flutter/material.dart';
import '../../../models/study_session.dart';
import '../../../theme/app_colors.dart';

class PlannedSessionItem extends StatelessWidget {
  final StudySession session;
  final String goalTitle;

  const PlannedSessionItem({
    super.key,
    required this.session,
    required this.goalTitle,
  });

  bool get _isCompleted => session.isCompleted;

  String _getDateText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate =
        DateTime(session.date.year, session.date.month, session.date.day);

    if (sessionDate == today) return 'Today';
    if (sessionDate == tomorrow) return 'Tomorrow';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${session.date.day} ${months[session.date.month - 1]}';
  }

  String _getTimeText() {
    if (session.startTime == null) return '';
    final hour = session.startTime!.hour;
    final minute = session.startTime!.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateText = _getDateText();
    final timeText = _getTimeText();
    final subtleColor = isDark
        ? const Color(0xFFa0cbc8)
        : AppColors.upcoming;

    return Opacity(
      opacity: _isCompleted ? 0.75 : 1.0,
      child: Container(
        color: isDark ? const Color(0xFF1a2e2d) : Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    session.notes?.isNotEmpty == true
                        ? session.notes!
                        : goalTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0d1c1b),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(isDark),
              ],
            ),
            const SizedBox(height: 8),
            // Date + time + duration row
            Row(
              children: [
                // Date
                Icon(Icons.event_outlined, size: 14, color: subtleColor),
                const SizedBox(width: 4),
                Text(
                  dateText,
                  style: TextStyle(fontSize: 12, color: subtleColor),
                ),
                if (timeText.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.schedule_outlined, size: 14, color: subtleColor),
                  const SizedBox(width: 4),
                  Text(
                    timeText,
                    style: TextStyle(fontSize: 12, color: subtleColor),
                  ),
                ],
                const Spacer(),
                Text(
                  session.formattedDuration,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0d1c1b),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.calendarAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 12,
                color: isDark ? AppColors.calendarAccent : AppColors.upcoming),
            const SizedBox(width: 3),
            Text(
              'DONE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.calendarAccent : AppColors.upcoming,
              ),
            ),
          ],
        ),
      );
    }

    // Upcoming / active
    final now = DateTime.now();
    final sessionDate =
        DateTime(session.date.year, session.date.month, session.date.day);
    final today = DateTime(now.year, now.month, now.day);
    final isToday = sessionDate == today;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.calendarAccent.withOpacity(isToday ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isToday ? 'TODAY' : 'UPCOMING',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.calendarAccent : const Color(0xFF0d1c1b),
        ),
      ),
    );
  }
}
