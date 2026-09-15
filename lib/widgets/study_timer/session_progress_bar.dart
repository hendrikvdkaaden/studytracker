import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class SessionProgressBar extends StatelessWidget {
  final int elapsedSeconds;
  final int targetMinutes;

  const SessionProgressBar({
    super.key,
    required this.elapsedSeconds,
    required this.targetMinutes,
  });

  double get _progressPercentage {
    if (targetMinutes == 0) return 0;
    final targetSeconds = targetMinutes * 60;
    final progress = (elapsedSeconds / targetSeconds).clamp(0.0, 1.0);
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_progressPercentage * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Session Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.textSecondary,
              ),
            ),
            Text(
              '$percentage% Completed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                // Normal-size text on a card: the mid-tone accent that dark
                // mode resolves to misses 4.5:1 for blue, purple and pink,
                // so the ink there is the normal one.
                color: context.colors.isDark
                    ? context.colors.textPrimary
                    : context.colors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.sectionBackground,
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
                        decoration: BoxDecoration(
                          color: context.colors.accentStrong,
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
    );
  }
}
