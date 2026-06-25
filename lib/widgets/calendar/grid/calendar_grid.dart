import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../../../services/goal_status_service.dart';
import '../../../utils/calendar_helpers.dart';
import 'calendar_day_builder.dart';
import 'weekday_headers.dart';

/// Main calendar grid widget that displays a month view with weekday headers
/// and a 7x5 grid of days
class CalendarGrid extends ConsumerWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  static const _calendarWeeks = 35;
  static const _daysPerWeek = 7;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusService = ref.watch(goalStatusServiceProvider);
    return Column(
      children: [
        const WeekdayHeaders(),
        _buildCalendarDaysGrid(statusService),
      ],
    );
  }

  Widget _buildCalendarDaysGrid(GoalStatusService statusService) {
    final calendarInfo = CalendarHelpers.getCalendarInfo(focusedMonth);
    final dayBuilder = CalendarDayBuilder(
      focusedMonth: focusedMonth,
      selectedDate: selectedDate,
      statusService: statusService,
      onDateSelected: onDateSelected,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _daysPerWeek,
        childAspectRatio: 1,
      ),
      itemCount: _calendarWeeks,
      itemBuilder: (context, index) => dayBuilder.buildDay(index, calendarInfo),
    );
  }
}
