import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../services/goal_repository.dart';
import '../../services/study_session_repository.dart';
import '../../theme/app_colors.dart';
import '../templates/home_template.dart';
import 'add_goal_screen.dart';
import 'goal_details_screen.dart';
import 'study_timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoalRepository _goalRepo = GoalRepository();
  final StudySessionRepository _sessionRepo = StudySessionRepository();
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  List<Goal> _getDeadlinesForDate(DateTime date) {
    return _goalRepo
        .getAllGoals()
        .where((goal) => !goal.isCompleted && _isSameDay(goal.date, date))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<StudySession> _getCompletedSessionsForDate(DateTime date) {
    return _sessionRepo
        .getPlannedSessionsByDate(date)
        .where((session) =>
            session.actualDuration != null &&
            session.actualDuration! >= session.duration)
        .toList()
      ..sort((a, b) {
        if (a.startTime != null && b.startTime != null) {
          return a.startTime!.compareTo(b.startTime!);
        }
        return 0;
      });
  }

  List<StudySession> _getPlannedSessionsForDate(DateTime date) {
    return _sessionRepo
        .getPlannedSessionsByDate(date)
        .where((session) =>
            session.actualDuration == null ||
            session.actualDuration! < session.duration)
        .toList()
      ..sort((a, b) {
        if (a.startTime != null && b.startTime != null) {
          return a.startTime!.compareTo(b.startTime!);
        }
        return 0;
      });
  }

  Map<String, Goal?> _getSessionGoals(List<StudySession> sessions) {
    final Map<String, Goal?> goals = {};
    for (var session in sessions) {
      goals[session.goalId] = _goalRepo.getGoalById(session.goalId);
    }
    return goals;
  }

  int _getTotalTasksToday() {
    final today = DateTime.now();
    final deadlines = _getDeadlinesForDate(today);
    final sessions = _sessionRepo.getPlannedSessionsByDate(today);
    return deadlines.length + sessions.length;
  }

  int _getCompletedTasksToday() {
    final today = DateTime.now();
    final completedSessions = _getCompletedSessionsForDate(today);
    final completedGoals = _goalRepo
        .getAllGoals()
        .where((goal) => goal.isCompleted && _isSameDay(goal.date, today))
        .length;
    return completedSessions.length + completedGoals;
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onDeadlineTap(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailsScreen(goal: goal),
      ),
    ).then((_) => setState(() {}));
  }

  void _onSessionTap(StudySession session) {
    final goal = _goalRepo.getGoalById(session.goalId);
    if (goal != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudyTimerScreen(
            session: session,
            goal: goal,
          ),
        ),
      ).then((_) => setState(() {}));
    }
  }

  void _onAddPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGoalScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final deadlines = _getDeadlinesForDate(_selectedDate);
    final completedSessions = _getCompletedSessionsForDate(_selectedDate);
    final plannedSessions = _getPlannedSessionsForDate(_selectedDate);
    final allSessions = [...completedSessions, ...plannedSessions];
    final sessionGoals = _getSessionGoals(allSessions);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: HomeTemplate(
          selectedDate: _selectedDate,
          deadlines: deadlines,
          completedSessions: completedSessions,
          plannedSessions: plannedSessions,
          sessionGoals: sessionGoals,
          totalTasksToday: _getTotalTasksToday(),
          completedTasksToday: _getCompletedTasksToday(),
          onDateSelected: _onDateSelected,
          onDeadlineTap: _onDeadlineTap,
          onSessionTap: _onSessionTap,
          onAddPressed: _onAddPressed,
        ),
      ),
    );
  }
}
