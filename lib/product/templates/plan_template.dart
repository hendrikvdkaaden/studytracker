import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../services/goal_repository.dart';
import '../../widgets/calendar/calendar_section.dart';
import '../../widgets/calendar/goals/date_header.dart';
import '../../widgets/calendar/calendar_day_content.dart';

/// Layout template for the plan/calendar screen
class PlanTemplate extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final GoalRepository goalRepo;
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
    required this.goalRepo,
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
          goalRepo: goalRepo,
          onPreviousMonth: onPreviousMonth,
          onNextMonth: onNextMonth,
          onDateSelected: onDateSelected,
        ),
        DateHeader(selectedDate: selectedDate),
        Expanded(
          child: CalendarDayContent(
            goals: goalsForSelectedDate,
            sessions: sessionsForSelectedDate,
            onGoalUpdated: onGoalUpdated,
          ),
        ),
      ],
    );
  }
}
