import 'package:flutter/material.dart';

class WeeklyGoalCard extends StatelessWidget {
  final double progressPercentage;

  const WeeklyGoalCard({
    super.key,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      height: 128,
      decoration: BoxDecoration(
        color: const Color(0xFF135BEC).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF135BEC).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'WEEKLY GOAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF135BEC),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep it up! ${progressPercentage.toInt()}% done',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0D121B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFF135BEC).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF135BEC).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: const Color(0xFF135BEC),
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
