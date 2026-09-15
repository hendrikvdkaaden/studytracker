import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../services/settings_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/goal_type_helper.dart';
import '../../../utils/l10n_extension.dart';
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

  Color _getStatusColor(BuildContext context) {
    final status = _getGoalStatus();
    switch (status) {
      case GoalStatus.overdue:
        return AppColors.overdue;
      case GoalStatus.upcoming:
        return context.colors.accent;
      case GoalStatus.completed:
        return AppColors.completed;
      case GoalStatus.session:
        return AppColors.iconPurple;
    }
  }

  String _getSubtitle(BuildContext context) {
    final l10n = context.l10n;
    if (goal.isCompleted) {
      return '${goal.subject} - ${l10n.deadlineStatusCompleted}';
    } else if (goal.isOverdue()) {
      final daysOverdue = goal.daysUntilDeadline().abs();
      return '${goal.subject} - ${l10n.deadlineStatusDaysOverdue(daysOverdue)}';
    } else {
      final hour = goal.date.hour;
      final minute = goal.date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${goal.subject} - Due at $displayHour:$minute $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getGoalStatus();
    final subtitle = _getSubtitle(context);
    final subjectColor = SettingsService.colorForSubject(goal.subject);

    final iconColor = subjectColor ??
        (status == GoalStatus.overdue ? AppColors.overdue : context.colors.accent);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.sectionBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colors.isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: context.colors.isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                GoalTypeHelper.getIconForType(goal.type),
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: status == GoalStatus.overdue
                          ? AppColors.overdue
                          : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status dot + chevron
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
