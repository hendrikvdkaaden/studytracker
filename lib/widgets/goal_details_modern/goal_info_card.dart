import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../utils/goal_type_helper.dart';

class GoalInfoCard extends StatelessWidget {
  final Goal goal;

  const GoalInfoCard({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2E2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF0DF2DF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              GoalTypeHelper.getIconForType(goal.type),
              color: isDark ? const Color(0xFF0DF2DF) : const Color(0xFF0D1C1B),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Title and Subject
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1C1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.subject} • Academic',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFA0CBC8) : const Color(0xFF499C95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
