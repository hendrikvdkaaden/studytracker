import 'package:flutter/material.dart';

class WeeklyProgressCard extends StatelessWidget {
  final int completedHours;
  final int targetHours;

  const WeeklyProgressCard({
    super.key,
    required this.completedHours,
    required this.targetHours,
  });

  double get _progressPercentage {
    if (targetHours == 0) return 0;
    return (completedHours / targetHours).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (_progressPercentage * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2b2930) : const Color(0xFFf3edf7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF6750A4).withOpacity(0.1),
        ),
      ),
      child: Stack(
        children: [
          // Glow effect in corner
          Positioned(
            right: -16,
            bottom: -16,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF6750A4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: const Color(0xFF6750A4),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WEEKLY GOAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6750A4),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Keep it up! $percentage% done',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1d1b20),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: constraints.maxWidth * _progressPercentage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF6750A4),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
