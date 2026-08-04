import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';
import 'grid/calendar_grid.dart';
import 'grid/month_navigation.dart';

class CalendarSection extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final Function(DateTime) onDateSelected;

  const CalendarSection({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.sectionBackground),
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
              onDateSelected: onDateSelected,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
