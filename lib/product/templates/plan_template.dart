import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/calendar/calendar_section.dart';
import '../../widgets/calendar/goals/date_header.dart';
import '../../widgets/calendar/calendar_day_content.dart';

/// Layout template for the plan/calendar screen
class PlanTemplate extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<Goal> goalsForSelectedDate;
  final List<StudySession> sessionsForSelectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final Function(DateTime) onDateSelected;
  final VoidCallback onGoalUpdated;

  const PlanTemplate({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.goalsForSelectedDate,
    required this.sessionsForSelectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
    required this.onGoalUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarSection(
          focusedMonth: focusedMonth,
          selectedDate: selectedDate,
          onPreviousMonth: onPreviousMonth,
          onNextMonth: onNextMonth,
          onDateSelected: onDateSelected,
        ),
        Expanded(
          child: Container(
            color: context.colors.background,
            child: Column(
              children: [
                DateHeader(selectedDate: selectedDate),
                Expanded(
                  child: CalendarDayContent(
                    goals: goalsForSelectedDate,
                    sessions: sessionsForSelectedDate,
                    onGoalUpdated: onGoalUpdated,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
