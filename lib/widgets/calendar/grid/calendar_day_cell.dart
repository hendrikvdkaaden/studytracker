import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isToday
              ? const Color(0xFF0DF2DF)
              : isSelected
                  ? (isDark
                      ? const Color(0xFF0DF2DF).withValues(alpha: 0.2)
                      : const Color(0xFF0DF2DF).withValues(alpha: 0.1))
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected && !isToday
              ? Border.all(
                  color: const Color(0xFF0DF2DF),
                  width: 2,
                )
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
                        ? (isDark ? Colors.grey[600] : Colors.grey[400])
                        : (isDark ? const Color(0xFFF8FCFB) : const Color(0xFF0D1C1B)),
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
        return const Color(0xFFFF5252);
      case GoalStatus.upcoming:
        return const Color(0xFF499C95);
      case GoalStatus.completed:
        return const Color(0xFF078830);
    }
  }
}

enum GoalStatus {
  overdue,
  upcoming,
  completed,
}
