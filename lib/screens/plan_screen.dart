import 'package:flutter/material.dart';
import '../services/goal_repository.dart';
import '../widgets/calendar/calendar_section.dart';
import '../widgets/calendar/goals/date_header.dart';
import '../widgets/calendar/goals/goals_list.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  static const _accentColor = Color(0xFF0DF2DF);
  static const _darkBackground = Color(0xFF102221);
  static const _lightBackground = Color(0xFFF5F8F8);

  final GoalRepository _goalRepo = GoalRepository();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsForSelectedDate = _goalRepo
        .getAllGoals()
        .where((goal) => _isSameDay(goal.date, _selectedDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: isDark ? _darkBackground : _lightBackground,
      body: Column(
        children: [
          CalendarSection(
            focusedMonth: _focusedMonth,
            selectedDate: _selectedDate,
            goalRepo: _goalRepo,
            onPreviousMonth: _previousMonth,
            onNextMonth: _nextMonth,
            onDateSelected: _onDateSelected,
          ),
          DateHeader(selectedDate: _selectedDate),
          Expanded(
            child: GoalsList(
              goals: goalsForSelectedDate,
              onGoalUpdated: () => setState(() {}),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToToday,
        backgroundColor: _accentColor,
        foregroundColor: _darkBackground,
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
