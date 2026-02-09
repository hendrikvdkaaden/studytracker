import 'package:flutter/material.dart';
import '../../widgets/study_timer/timer_display.dart';
import '../../widgets/study_timer/session_info_card.dart';
import '../../widgets/study_timer/session_progress_bar.dart';
import '../../widgets/study_timer/timer_controls.dart';

class StudyTimerTemplate extends StatelessWidget {
  final String goalTitle;
  final String subject;
  final int elapsedSeconds;
  final int targetMinutes;
  final TimerState timerState;
  final VoidCallback onBack;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onComplete;

  const StudyTimerTemplate({
    super.key,
    required this.goalTitle,
    required this.subject,
    required this.elapsedSeconds,
    required this.targetMinutes,
    required this.timerState,
    required this.onBack,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onComplete,
  });

  String _getPhaseLabel() {
    if (timerState == TimerState.initial) {
      return 'Ready to Focus';
    }
    if (timerState == TimerState.paused) {
      return 'Paused';
    }
    if (targetMinutes == 0) {
      return 'Deep Focus Phase';
    }

    final targetSeconds = targetMinutes * 60;
    final progress = elapsedSeconds / targetSeconds;

    if (progress < 0.25) {
      return 'Getting Started';
    } else if (progress < 0.75) {
      return 'Deep Focus Phase';
    } else if (progress < 1.0) {
      return 'Final Push';
    } else {
      return 'Overtime';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.grey[800]?.withOpacity(0.5)
                          : Colors.grey[200]?.withOpacity(0.5),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'CURRENTLY STUDYING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[900],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline),
                    iconSize: 30,
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Timer Display
                    TimerDisplay(
                      elapsedSeconds: elapsedSeconds,
                      phaseLabel: _getPhaseLabel(),
                    ),
                    const SizedBox(height: 64),
                    // Session Info
                    SessionInfoCard(
                      targetMinutes: targetMinutes,
                      elapsedSeconds: elapsedSeconds,
                    ),
                    const SizedBox(height: 32),
                    // Progress Bar
                    SessionProgressBar(
                      elapsedSeconds: elapsedSeconds,
                      targetMinutes: targetMinutes,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Controls
            Container(
              padding: const EdgeInsets.all(24),
              child: TimerControls(
                state: timerState,
                onStart: onStart,
                onPause: onPause,
                onResume: onResume,
                onStop: onStop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
