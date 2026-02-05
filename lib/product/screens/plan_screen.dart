import 'package:flutter/material.dart';

import '../../services/goal_repository.dart';
import '../../services/study_session_repository.dart';
import '../../theme/app_colors.dart';
import '../templates/plan_template.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final GoalRepository _goalRepo = GoalRepository();
  final StudySessionRepository _sessionRepo = StudySessionRepository();
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }
  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }
  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedMonth = DateTime.now();
    });
  }
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final goalsForSelectedDate = _goalRepo
        .getAllGoals()
        .where((goal) => _isSameDay(goal.date, _selectedDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final sessionsForSelectedDate =
        _sessionRepo.getPlannedSessionsByDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.getCalendarBackground(context),
      body: PlanTemplate(
        focusedMonth: _focusedMonth,
        selectedDate: _selectedDate,
        goalRepo: _goalRepo,
        goalsForSelectedDate: goalsForSelectedDate,
        sessionsForSelectedDate: sessionsForSelectedDate,
        onPreviousMonth: _previousMonth,
        onNextMonth: _nextMonth,
        onDateSelected: _onDateSelected,
        onGoalUpdated: () => setState(() {}),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToToday,
        backgroundColor: AppColors.calendarAccent,
        foregroundColor: AppColors.calendarDarkBackground,
        child: const Text(
          'Today',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
