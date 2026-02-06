import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum TimerState { initial, running, paused, completed }

class TimerControls extends StatelessWidget {
  final TimerState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const TimerControls({
    super.key,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Stop button
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 64,
            child: OutlinedButton(
              onPressed: state == TimerState.initial ? null : onStop,
              style: OutlinedButton.styleFrom(
                backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                side: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stop_circle_outlined,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stop',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Primary action button (Start/Pause/Resume)
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: _getPrimaryAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.calendarAccent,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: AppColors.calendarAccent.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getPrimaryIcon(),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPrimaryLabel(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  VoidCallback _getPrimaryAction() {
    switch (state) {
      case TimerState.initial:
        return onStart;
      case TimerState.running:
        return onPause;
      case TimerState.paused:
        return onResume;
      case TimerState.completed:
        return onStart; // Restart
    }
  }

  IconData _getPrimaryIcon() {
    switch (state) {
      case TimerState.initial:
        return Icons.play_circle_outline;
      case TimerState.running:
        return Icons.pause_circle_outline;
      case TimerState.paused:
        return Icons.play_circle_outline;
      case TimerState.completed:
        return Icons.restart_alt;
    }
  }

  String _getPrimaryLabel() {
    switch (state) {
      case TimerState.initial:
        return 'Start Session';
      case TimerState.running:
        return 'Pause Session';
      case TimerState.paused:
        return 'Resume';
      case TimerState.completed:
        return 'Restart';
    }
  }
}
