import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../theme/app_theme_extension.dart';
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
    final progress = targetTime > 0 ? (timeSpent / targetTime).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();
    final color = accentColor ?? context.colors.accentStrong;
    final formatTime = FormatHelpers.formatTime;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.fieldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.border,
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
                color: color,
                trackColor: context.colors.accentAlpha(color,
                    darkAlpha: 0.2, lightAlpha: 0.15),
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
                        color: context.colors.textPrimary,
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
                        color: context.colors.accentAlpha(color),
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
                          color: context.colors.textPrimary,
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
                          color: context.colors.textPrimary,
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
  /// Kept as the default so the goal-details circle is unchanged; the timer
  /// ring passes something much thinner.
  static const double defaultStrokeWidth = 16.0;

  final double progress;
  final Color color;
  final double strokeWidth;

  /// The unfilled track, already resolved against the theme by the caller —
  /// a painter has no BuildContext, so it takes the colour rather than a
  /// brightness flag to branch on.
  final Color trackColor;

  /// Overrides [trackColor]'s own alpha. Pulled out so the timer ring can
  /// breathe by animating it.
  final double? trackAlpha;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    this.strokeWidth = defaultStrokeWidth,
    this.trackAlpha,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle — tinted version of the accent color
    final backgroundPaint = Paint()
      ..color = trackAlpha == null
          ? trackColor
          : trackColor.withValues(alpha: trackAlpha!)
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
        oldDelegate.trackColor != trackColor ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackAlpha != trackAlpha;
  }
}
