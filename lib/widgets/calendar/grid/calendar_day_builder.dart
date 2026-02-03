import 'package:flutter/material.dart';
import '../../../services/goal_repository.dart';
import '../../../services/goal_status_service.dart';
import '../../../utils/calendar_helpers.dart';
import 'calendar_day_cell.dart';

/// Builds calendar day cells for the calendar grid
class CalendarDayBuilder {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final GoalRepository goalRepo;
  final Function(DateTime) onDateSelected;
  final GoalStatusService _statusService;

  CalendarDayBuilder({
    required this.focusedMonth,
    required this.selectedDate,
    required this.goalRepo,
    required this.onDateSelected,
  }) : _statusService = GoalStatusService(goalRepo);

  /// Builds a calendar cell based on its position in the grid
  Widget buildDay(int index, CalendarInfo info) {
    final dayOffset = index - info.startingWeekday;
    final cellType = CalendarHelpers.determineCellType(
      dayOffset,
      info.daysInMonth,
    );

    return switch (cellType) {
      CellType.previousMonth => _buildAdjacentMonthDay(
          CalendarHelpers.calculatePreviousMonthDay(
            dayOffset,
            info.daysInPreviousMonth,
          ),
        ),
      CellType.nextMonth => _buildAdjacentMonthDay(
          CalendarHelpers.calculateNextMonthDay(dayOffset, info.daysInMonth),
        ),
      CellType.currentMonth => _buildCurrentMonthDay(dayOffset + 1),
    };
  }

  Widget _buildAdjacentMonthDay(int day) {
    return CalendarDayCell(
      day: day,
      isCurrentMonth: false,
      statuses: const [],
      onTap: () {},
    );
  }

  Widget _buildCurrentMonthDay(int day) {
    final date = DateTime(focusedMonth.year, focusedMonth.month, day);
    final now = DateTime.now();

    return CalendarDayCell(
      day: day,
      isCurrentMonth: true,
      isToday: CalendarHelpers.isSameDay(date, now),
      isSelected: CalendarHelpers.isSameDay(date, selectedDate),
      statuses: _statusService.getStatusesForDate(date),
      onTap: () => onDateSelected(date),
    );
  }
}
