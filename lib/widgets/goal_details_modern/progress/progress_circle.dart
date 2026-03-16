import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../theme/app_colors.dart';
import '../../../utils/format_helpers.dart';

class ProgressCircle extends StatelessWidget {
  final int timeSpent; // in minutes
  final int targetTime; // in minutes
  final Color? accentColor;

  const ProgressCircle({
    super.key,
    required this.timeSpent,
    required this.targetTime,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = targetTime > 0 ? (timeSpent / targetTime).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();
    final color = accentColor ?? AppColors.calendarAccent;
    final formatTime = FormatHelpers.formatTime;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkFieldBackground : AppColors.lightFieldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          // Circular Progress
          SizedBox(
            width: 192,
            height: 192,
            child: CustomPaint(
              painter: CircularProgressPainter(
                progress: progress,
                isDark: isDark,
                color: color,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Time Stats
          Row(
            children: [
              // Time Spent
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: color.withValues(alpha: isDark ? 0.3 : 0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TIME SPENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTime(timeSpent),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Target Time
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      Text(
                        'TARGET TIME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTime(targetTime),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ],
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

class CircularProgressPainter extends CustomPainter {
  static const double strokeWidth = 16.0;

  final double progress;
  final bool isDark;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.isDark,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle — tinted version of the accent color
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.2 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.color != color;
  }
}
