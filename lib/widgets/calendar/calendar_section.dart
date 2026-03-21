import 'package:flutter/material.dart';
import '../../services/goal_repository.dart';
import '../../theme/app_colors.dart';
import 'grid/calendar_grid.dart';
import 'grid/month_navigation.dart';

class CalendarSection extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final GoalRepository goalRepo;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final Function(DateTime) onDateSelected;

  static const _darkBorder = AppColors.sectionDarkBg;
  static const _lightBorder = AppColors.lightFieldBackground;

  const CalendarSection({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.goalRepo,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? _darkBorder : _lightBorder),
        ),
      ),
      child: Column(
        children: [
          MonthNavigation(
            focusedMonth: focusedMonth,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CalendarGrid(
              focusedMonth: focusedMonth,
              selectedDate: selectedDate,
              goalRepo: goalRepo,
              onDateSelected: onDateSelected,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
