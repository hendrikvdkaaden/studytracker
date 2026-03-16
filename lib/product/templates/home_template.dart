import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/home/date_selector.dart';
import '../../widgets/home/home_section_header.dart';
import '../../widgets/home/deadline_card.dart';
import '../../widgets/home/session_item.dart';

class HomeTemplate extends StatelessWidget {
  final DateTime selectedDate;
  final List<Goal> deadlines;
  final List<StudySession> sessions;
  final Map<String, Goal?> sessionGoals;
  final int totalTasksToday;
  final int completedTasksToday;
  final Function(DateTime) onDateSelected;
  final Function(Goal) onDeadlineTap;
  final Function(StudySession) onSessionTap;
  final bool Function(StudySession) isSessionCompleted;

  const HomeTemplate({
    super.key,
    required this.selectedDate,
    required this.deadlines,
    required this.sessions,
    required this.sessionGoals,
    required this.totalTasksToday,
    required this.completedTasksToday,
    required this.onDateSelected,
    required this.onDeadlineTap,
    required this.onSessionTap,
    required this.isSessionCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final totalSessions = sessions.length;
    final completedSessionsCount = sessions.where((s) => isSessionCompleted(s)).length;
    final hasAnyItems = deadlines.isNotEmpty || totalSessions > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DateSelector(
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
          ),
        ),
        if (!hasAnyItems)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 64,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.homeNoTasksTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.homeNoTasksSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (deadlines.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: HomeSectionHeader(
                title: context.l10n.homeDeadlinesToday,
                remainingCount: deadlines.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HomeDeadlineCard(
                    goal: deadlines[index],
                    onTap: () => onDeadlineTap(deadlines[index]),
                  ),
                );
              }, childCount: deadlines.length),
            ),
          ),
        ],
        if (sessions.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: HomeSectionHeader(
                title: context.l10n.homeStudySessions,
                completedCount: completedSessionsCount,
                totalCount: totalSessions,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final session = sessions[index];
                  return HomeSessionItem(
                    session: session,
                    goal: sessionGoals[session.goalId],
                    isCompleted: isSessionCompleted(session),
                    isLast: index == sessions.length - 1,
                    onTap: () => onSessionTap(session),
                  );
                },
                childCount: sessions.length,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
