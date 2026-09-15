import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final String phaseLabel;

  const TimerDisplay({
    super.key,
    required this.remainingSeconds,
    required this.phaseLabel,
  });

  String _formatTime() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _formatTime(),
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            // accent, not accentStrong: this is text on a card, and the
            // strong mid-tone only clears 4.5:1 against a dark surface.
            // accent already resolves to it in dark mode.
            color: context.colors.accent,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.accentStrong.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.colors.accentStrong.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt,
                size: 16,
                color: context.colors.accentStrong,
              ),
              const SizedBox(width: 6),
              Text(
                phaseLabel,
                style: TextStyle(
                  fontSize: 14,
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
