import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../widgets/home/progress_header.dart';
import '../../widgets/home/date_selector.dart';
import '../../widgets/home/home_section_header.dart';
import '../../widgets/home/deadline_card.dart';
import '../../widgets/home/session_item.dart';

class HomeTemplate extends StatelessWidget {
  final DateTime selectedDate;
  final List<Goal> deadlines;
  final List<StudySession> completedSessions;
  final List<StudySession> plannedSessions;
  final Map<String, Goal?> sessionGoals;
  final int totalTasksToday;
  final int completedTasksToday;
  final Function(DateTime) onDateSelected;
  final Function(Goal) onDeadlineTap;
  final VoidCallback onAddPressed;

  const HomeTemplate({
    super.key,
    required this.selectedDate,
    required this.deadlines,
    required this.completedSessions,
    required this.plannedSessions,
    required this.sessionGoals,
    required this.totalTasksToday,
    required this.completedTasksToday,
    required this.onDateSelected,
    required this.onDeadlineTap,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final totalSessions = completedSessions.length + plannedSessions.length;
    final completedSessionsCount = completedSessions.length;
    final hasAnyItems = deadlines.isNotEmpty || totalSessions > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProgressHeader(
                completedCount: completedTasksToday,
                totalCount: totalTasksToday,
              ),
            ),
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
                          'No tasks for this day',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select another day or add a new goal',
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
                    title: 'Deadlines Today',
                    remainingCount: deadlines.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HomeDeadlineCard(
                          goal: deadlines[index],
                          onTap: () => onDeadlineTap(deadlines[index]),
                        ),
                      );
                    },
                    childCount: deadlines.length,
                  ),
                ),
              ),
            ],
            if (completedSessions.isNotEmpty || plannedSessions.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: HomeSectionHeader(
                    title: 'Study Sessions',
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
                      if (index < completedSessions.length) {
                        final session = completedSessions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HomeSessionItem(
                            session: session,
                            goal: sessionGoals[session.goalId],
                            isCompleted: true,
                          ),
                        );
                      } else {
                        final plannedIndex = index - completedSessions.length;
                        final session = plannedSessions[plannedIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HomeSessionItem(
                            session: session,
                            goal: sessionGoals[session.goalId],
                            isCompleted: false,
                          ),
                        );
                      }
                    },
                    childCount: completedSessions.length + plannedSessions.length,
                  ),
                ),
              ),
            ],
          ],
        ),
        Positioned(
          bottom: 32,
          right: 24,
          child: FloatingActionButton(
            onPressed: onAddPressed,
            backgroundColor: const Color(0xFF4f46e5),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
}
