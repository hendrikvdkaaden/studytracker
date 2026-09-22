import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';

class TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final String phaseLabel;

  /// Session progress, 0-100. Shown here because the progress bar that used
  /// to carry it is gone; this is the only place the figure appears.
  ///
  /// Supplied by TimerProgressRing from the same continuous value that draws
  /// the arc, so the number and the ring it sits inside never disagree --
  /// computing it separately from whole seconds let the text read 99% at the
  /// moment the arc visually closed.
  final int progressPercentage;

  const TimerDisplay({
    super.key,
    required this.remainingSeconds,
    required this.phaseLabel,
    required this.progressPercentage,
  });

  String _formatTime() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatTime(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: context.colors.accent,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.timerProgressPercent(progressPercentage),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.accentText,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: context.colors.accentStrong.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: context.colors.accentStrong.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt,
                size: 11,
                color: context.colors.accentStrong,
              ),
              const SizedBox(width: 3),
              Text(
                phaseLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
