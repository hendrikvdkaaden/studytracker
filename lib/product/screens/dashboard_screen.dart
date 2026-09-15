import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal.dart';
import '../../theme/app_theme_extension.dart';
import '../../models/day_status.dart';
import '../../models/study_session.dart';
import '../../providers/app_providers.dart';
import '../../services/goal_repository.dart';
import '../../services/settings_service.dart';
import '../../services/streak_service.dart';
import '../../services/study_session_repository.dart';
import '../../utils/calendar_helpers.dart';
import '../templates/dashboard_template.dart';
import 'add_goal_screen.dart';
import 'goal_details_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  /// Recomputes the dashboard from Hive. Needed because HomePage keeps this
  /// screen alive in an IndexedStack, so returning to the tab does not rebuild.
  void refresh() {
    if (mounted) setState(() {});
  }

  late bool _completedCollapsed = SettingsService.completedCollapsed;

  Future<void> _toggleCompleted() async {
    final collapsed = !_completedCollapsed;
    setState(() => _completedCollapsed = collapsed);
    await SettingsService.setCompletedCollapsed(collapsed);
  }

  GoalRepository get _goalRepo => ref.read(goalRepositoryProvider);
  StudySessionRepository get _sessionRepo => ref.read(studySessionRepositoryProvider);

  bool _isCompletedOnTime(StudySession s) => StreakService.isCompletedOnTime(s);

  bool _isMissed(StudySession s, DateTime now) =>
      StreakService.isMissed(s, now);

  Map<int, DayStatus> _getWeeklyConsistency() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = CalendarHelpers.getStartOfWeek(now);

    Map<int, DayStatus> weekData = {};

    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );
      final weekday = i + 1; // 1=Monday, 7=Sunday

      final allSessions = _sessionRepo.getSessionsByDateRange(
        date,
        date.add(const Duration(days: 1)),
      );

      final isPastDay = date.isBefore(today);
      final allCompletedOnTime = allSessions.isNotEmpty &&
          allSessions.every(_isCompletedOnTime);
      final hasMissed = allSessions.any((s) => _isMissed(s, now));

      if (allCompletedOnTime) {
        weekData[weekday] = DayStatus.completed;
      } else if (hasMissed) {
        weekData[weekday] = DayStatus.missed;
      } else if (isPastDay) {
        weekData[weekday] = DayStatus.pastNoSession;
      } else {
        weekData[weekday] = DayStatus.notPlanned;
      }
    }

    return weekData;
  }

  int _getMissedSessionsCount() {
    final now = DateTime.now();
    final startOfWeek = CalendarHelpers.getStartOfWeek(now);

    int missedCount = 0;

    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );

      final allSessions = _sessionRepo.getSessionsByDateRange(
        date,
        date.add(const Duration(days: 1)),
      );

      missedCount += allSessions.where((s) => _isMissed(s, now)).length;
    }

    return missedCount;
  }

  int _getStudyStreak() => StreakService.calculateStreak(
        sessions: _sessionRepo.getAllSessions(),
        now: DateTime.now(),
      );

  Map<String, int> _getGoalsTimeSpent() {
    final Map<String, int> timeSpent = {};
    for (var goal in _goalRepo.getAllGoals()) {
      timeSpent[goal.id] = _sessionRepo.getTotalStudyTimeForGoal(goal.id);
    }
    return timeSpent;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: context.colors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: _navigateToAddGoal,
        backgroundColor: context.colors.accent.withValues(alpha: 0.96),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: DashboardTemplate(
        weeklyConsistency: _getWeeklyConsistency(),
        missedSessionsCount: _getMissedSessionsCount(),
        studyStreak: _getStudyStreak(),
        overdueGoals: _goalRepo.getOverdueGoals(),
        upcomingGoals: _goalRepo.getUpcomingGoals(30),
        completedGoals: _goalRepo.getCompletedGoals(),
        goalsTimeSpent: _getGoalsTimeSpent(),
        onGoalTap: _navigateToDetails,
        completedCollapsed: _completedCollapsed,
        onToggleCompleted: _toggleCompleted,
      ),
    );
  }

  void _navigateToDetails(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailsScreen(goal: goal),
      ),
    ).then((_) => setState(() {}));
  }

  void _navigateToAddGoal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGoalScreen(),
      ),
    ).then((_) => setState(() {}));
  }
}
