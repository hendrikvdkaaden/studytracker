import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';

class CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<GoalStatus> statuses;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    this.isCurrentMonth = true,
    this.isToday = false,
    this.isSelected = false,
    this.statuses = const [],
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.calendarAccent
              : isSelected
                  ? AppColors.calendarAccent.withValues(alpha: context.colors.isDark ? 0.24 : 0.14)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected && !isToday
              ? Border.all(
                  color: AppColors.calendarAccent,
                  width: 2.5,
                )
              : null,
          boxShadow: isSelected && !isToday
              ? [
                  BoxShadow(
                    color: AppColors.calendarAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                color: isToday
                    ? const Color(0xFF0D1C1B)
                    : !isCurrentMonth
                        ? context.colors.textTertiary
                        : context.colors.textPrimary,
              ),
            ),
            if (statuses.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: statuses.take(3).map((status) {
                  return Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.overdue:
        return AppColors.overdue;
      case GoalStatus.upcoming:
        return AppColors.primaryLight;
      case GoalStatus.completed:
        return AppColors.completed;
      case GoalStatus.session:
        return AppColors.iconPurple;
    }
  }
}

enum GoalStatus {
  overdue,
  upcoming,
  completed,
  session,
}
