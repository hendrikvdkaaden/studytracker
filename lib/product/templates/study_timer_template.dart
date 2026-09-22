import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/study_timer/timer_display.dart';
import '../../widgets/study_timer/timer_progress_ring.dart';
import '../../widgets/study_timer/session_info_card.dart';
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
  final ConfettiController confettiController;

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
    required this.confettiController,
  });

  String _getPhaseLabel(BuildContext context) {
    final l10n = context.l10n;

    if (timerState == TimerState.initial) {
      return l10n.timerPhaseReady;
    }
    if (timerState == TimerState.completed) {
      return l10n.timerPhaseCompleted;
    }
    if (timerState == TimerState.paused) {
      return l10n.timerPhasePaused;
    }
    if (targetMinutes == 0) {
      return l10n.timerPhaseDeepFocus;
    }

    final targetSeconds = targetMinutes * 60;
    final progress = elapsedSeconds / targetSeconds;

    if (progress < 0.25) {
      return l10n.timerPhaseGettingStarted;
    } else if (progress < 0.75) {
      return l10n.timerPhaseDeepFocus;
    } else {
      return l10n.timerPhaseFinalPush;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          SafeArea(
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
                          backgroundColor:
                              context.colors.sectionBackground.withValues(alpha: 0.5),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              context.l10n.timerHeaderCurrentlyStudying,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textSecondary,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subject,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textPrimary,
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
                    // The spacing below is what closes the gap that used to
                    // sit under the session card. A mainAxisAlignment would
                    // not: a Column inside a SingleChildScrollView gets an
                    // unbounded main axis, shrink-wraps its children, and so
                    // has no free space to distribute.
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        TimerProgressRing(
                          elapsedSeconds: elapsedSeconds,
                          targetMinutes: targetMinutes,
                          timerState: timerState,
                          childBuilder: (context, progressPercentage) =>
                              TimerDisplay(
                            remainingSeconds: ((targetMinutes * 60) - elapsedSeconds).clamp(0, targetMinutes * 60),
                            phaseLabel: _getPhaseLabel(context),
                            progressPercentage: progressPercentage,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Session Info
                        SessionInfoCard(
                          targetMinutes: targetMinutes,
                          elapsedSeconds: elapsedSeconds,
                        ),
                        const SizedBox(height: 40),
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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.08,
              numberOfParticles: 80,
              maxBlastForce: 30,
              minBlastForce: 10,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
