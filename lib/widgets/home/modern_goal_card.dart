import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../utils/goal_type_helper.dart';
import '../../services/study_session_repository.dart';

class ModernGoalCard extends StatelessWidget {
  final Goal goal;
  final bool isOverdue;
  final bool isCompleted;
  final VoidCallback onTap;

  const ModernGoalCard({
    super.key,
    required this.goal,
    this.isOverdue = false,
    this.isCompleted = false,
    required this.onTap,
  });

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = goal.daysUntilDeadline();

    // Status color and icon
    Color statusColor;
    Color iconBgColor;
    IconData statusIcon;
    String statusText;

    if (isCompleted) {
      statusColor = Colors.green;
      iconBgColor = isDark ? Colors.green.withOpacity(0.3) : Colors.green.shade100;
      statusIcon = Icons.check_circle;
      statusText = '';
    } else if (isOverdue) {
      statusColor = Colors.red;
      iconBgColor = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade100;
      statusIcon = Icons.error;
      statusText = '${daysLeft.abs()}d overdue';
    } else if (daysLeft <= 3) {
      statusColor = Colors.orange;
      iconBgColor = isDark ? const Color(0xFF135BEC).withOpacity(0.1) : const Color(0xFF135BEC).withOpacity(0.1);
      statusIcon = Icons.schedule;
      statusText = '${daysLeft}d left';
    } else {
      statusColor = const Color(0xFF135BEC);
      iconBgColor = isDark ? const Color(0xFF135BEC).withOpacity(0.1) : const Color(0xFF135BEC).withOpacity(0.1);
      statusIcon = Icons.schedule;
      statusText = '${daysLeft}d left';
    }

    final studySessionRepo = StudySessionRepository();
    final totalStudied = studySessionRepo.getTotalStudyTimeForGoal(goal.id);
    final targetTime = goal.studyTime;
    final progress = targetTime > 0 ? (totalStudied / targetTime).clamp(0.0, 1.0) : 0.0;
    final progressColor = isCompleted ? Colors.green : Colors.teal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon, title, and status
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      GoalTypeHelper.getIconForType(goal.type),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title and subject
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0D121B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          goal.subject,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicator
                  if (!isCompleted && statusText.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  if (isCompleted)
                    Icon(
                      statusIcon,
                      size: 24,
                      color: statusColor,
                    ),
                ],
              ),

              // Progress section (if study time exists)
              if (goal.studyTime > 0) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isCompleted ? 'Completed' : 'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      '${_formatTime(totalStudied)} / ${_formatTime(targetTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],

              // Overdue error message
              if (isOverdue && !isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.error,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${daysLeft.abs()} day${daysLeft.abs() == 1 ? '' : 's'} overdue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
