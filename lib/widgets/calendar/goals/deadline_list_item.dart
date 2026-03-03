import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../services/settings_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/goal_type_helper.dart';
import '../grid/calendar_day_cell.dart';

class DeadlineListItem extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const DeadlineListItem({
    super.key,
    required this.goal,
    required this.onTap,
  });

  GoalStatus _getGoalStatus() {
    if (goal.isCompleted) return GoalStatus.completed;
    if (goal.isOverdue()) return GoalStatus.overdue;
    return GoalStatus.upcoming;
  }

  Color _getStatusColor() {
    final status = _getGoalStatus();
    switch (status) {
      case GoalStatus.overdue:
        return AppColors.overdue;
      case GoalStatus.upcoming:
        return AppColors.upcoming;
      case GoalStatus.completed:
        return AppColors.completed;
    }
  }

  Color _getIconBackgroundColor() {
    final status = _getGoalStatus();
    switch (status) {
      case GoalStatus.overdue:
        return AppColors.overdue.withValues(alpha: 0.1);
      case GoalStatus.upcoming:
      case GoalStatus.completed:
        return AppColors.calendarAccent.withValues(alpha: 0.2);
    }
  }

  String _getSubtitle() {
    if (goal.isCompleted) {
      return '${goal.subject} - Completed';
    } else if (goal.isOverdue()) {
      final daysOverdue = goal.daysUntilDeadline().abs();
      return '${goal.subject} - Overdue ($daysOverdue day${daysOverdue == 1 ? '' : 's'})';
    } else {
      // Format time if available
      final hour = goal.date.hour;
      final minute = goal.date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${goal.subject} - Due at $displayHour:$minute $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = _getGoalStatus();
    final subjectColor = SettingsService.colorForSubject(goal.subject);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.calendarDarkBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getBorderColor(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: subjectColor != null
                    ? subjectColor.withValues(alpha: 0.15)
                    : _getIconBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                GoalTypeHelper.getIconForType(goal.type),
                color: subjectColor ??
                    (status == GoalStatus.overdue
                        ? AppColors.overdue
                        : (isDark
                            ? AppColors.calendarAccent
                            : AppColors.upcoming)),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF8FCFB) : const Color(0xFF0D1C1B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getSubtitle(),
                    style: TextStyle(
                      fontSize: 14,
                      color: status == GoalStatus.overdue
                          ? AppColors.overdue
                          : (isDark
                              ? AppColors.calendarAccent.withValues(alpha: 0.7)
                              : AppColors.upcoming),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status indicator and chevron
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
