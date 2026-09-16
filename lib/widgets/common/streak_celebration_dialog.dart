import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/streak_freeze_service.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';

/// Celebrates the streak growing by one.
Future<void> showStreakCelebrationDialog({
  required BuildContext context,
  required int streak,
}) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (_) => _CelebrationDialog(
      title: l10n.streakCelebrationTitle(streak),
      message: l10n.streakCelebrationBody(streak),
      buttonLabel: l10n.streakCelebrationButton,
      hero: _StreakHero(streak: streak),
      celebratory: true,
    ),
  );
}

/// Reports that a freeze covered a missed day.
///
/// Same shell as the celebration, quieter delivery: no confetti, no haptics,
/// no counting number. A rescue is news, not an achievement -- dressing it up
/// as one would congratulate the user for a day they did not study.
Future<void> showFreezeRescueDialog({
  required BuildContext context,
  required FreezeOutcome outcome,
}) {
  final l10n = context.l10n;
  final days = outcome.daysFrozen.length;
  return showDialog<void>(
    context: context,
    builder: (_) => _CelebrationDialog(
      title: l10n.streakFreezeTitle,
      message: days == 1
          ? l10n.streakFreezeUsed(outcome.freezesAvailable)
          : l10n.streakFreezeUsedPlural(days, outcome.freezesAvailable),
      buttonLabel: l10n.btnClose,
      hero: const _FreezeHero(),
      celebratory: false,
    ),
  );
}

/// The shared shell.
///
/// Deliberately not built on [showAppMessageDialog]: that takes a String and
/// nothing else, so there is no room for a hero widget and no Stack to hang
/// confetti in. This copies its visual recipe instead -- the same surface,
/// inset, radius and gradient button -- which is what premium_gate_bottom_sheet
/// does for the same reason.
class _CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final Widget hero;

  /// Adds confetti and the app's haptic celebration pattern.
  final bool celebratory;

  const _CelebrationDialog({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.hero,
    required this.celebratory,
  });

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog> {
  ConfettiController? _confetti;

  /// The delayed haptic beats, kept so dispose can cancel them.
  final List<Timer> _hapticBeats = [];

  @override
  void initState() {
    super.initState();
    if (!widget.celebratory) return;

    // 200ms, not 3s: the controller emits for as long as it runs, so a long
    // duration reads as repeated bursts rather than one.
    _confetti = ConfettiController(duration: const Duration(milliseconds: 200));
    // Fired from a post-frame callback so the first frame is painted before
    // the burst starts, matching how the timer screen does it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confetti?.play();
      _celebrationHaptics();
    });
  }

  /// The three-beat pulse the timer screen already uses on completion.
  ///
  /// The two delayed beats are held so they can be cancelled: dismissing the
  /// dialog inside 400ms would otherwise leave the phone buzzing after it had
  /// gone, and in tests the pending timers outlive the widget tree.
  void _celebrationHaptics() {
    HapticFeedback.heavyImpact();
    _hapticBeats.add(
      Timer(const Duration(milliseconds: 200), HapticFeedback.heavyImpact),
    );
    _hapticBeats.add(
      Timer(const Duration(milliseconds: 400), HapticFeedback.heavyImpact),
    );
  }

  @override
  void dispose() {
    for (final beat in _hapticBeats) {
      beat.cancel();
    }
    _confetti?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.modalBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.hero,
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildButton(context),
              ],
            ),
          ),
          if (_confetti != null)
            ConfettiWidget(
              confettiController: _confetti!,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              // All at once: emissionFrequency drives how often it emits
              // while running, so 1.0 plus a short duration gives exactly
              // one volley.
              emissionFrequency: 1.0,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.25,
            ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.accent, colors.accentStrong],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          // Borrowed from the bottom-sheet button: a little glow suits the
          // moment better than the flat dialog button.
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size(0, 50),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.buttonLabel,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The flame, springing in and counting up to the new total.
class _StreakHero extends StatelessWidget {
  final int streak;

  const _StreakHero({required this.streak});

  /// How much of the run is spent holding the old number before it moves.
  ///
  /// Without a hold the previous total is gone before the eye lands on it, and
  /// the slide reads as a single number appearing oddly rather than one
  /// replacing another.
  static const double _holdFraction = 0.35;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      builder: (context, t, child) {
        // The flame springs in on the app's one celebratory curve, the same
        // overshoot the splash logo uses.
        final entry = Curves.easeOutBack.transform(t.clamp(0.0, 1.0));

        // The slide starts only after the hold, and eases rather than
        // overshooting -- a digit that springs past its box and back reads as
        // a glitch, where a logo doing it reads as bounce.
        final rawSlide =
            ((t - _holdFraction) / (1 - _holdFraction)).clamp(0.0, 1.0);
        final slide = Curves.easeInOut.transform(rawSlide);

        return Transform.scale(
          scale: 0.4 + (0.6 * entry),
          child: _FlameWithCount(
            previous: streak - 1,
            current: streak,
            slide: slide,
          ),
        );
      },
    );
  }
}

/// Flame and number drawn separately, so the flame holds still while the old
/// number is pushed out by the new one.
///
/// Both numbers are mounted at once and moved by [slide]: 0 shows the previous
/// total in place, 1 shows the current one. A ClipRect keeps whichever is
/// mid-travel from spilling outside the digit box.
class _FlameWithCount extends StatelessWidget {
  final int previous;
  final int current;

  /// 0 = old number in place, 1 = new number in place.
  final double slide;

  const _FlameWithCount({
    required this.previous,
    required this.current,
    required this.slide,
  });

  /// Tall enough for the 45px digits, and the distance each travels.
  static const double _digitHeight = 56;

  @override
  Widget build(BuildContext context) {
    final colour = context.colors.streakFlame;

    final style = TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.bold,
      color: colour,
    );

    // Sized to the wider of the two, so the row does not jump when the digit
    // count changes (9 -> 10).
    final width = _digitWidth(context, current, style);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department, size: 48, color: colour),
        const SizedBox(width: 2),
        ClipRect(
          child: SizedBox(
            height: _digitHeight,
            width: width,
            child: Stack(
              children: [
                // Leaves upward.
                Transform.translate(
                  offset: Offset(0, -_digitHeight * slide),
                  child: _digit(previous, style),
                ),
                // Arrives from below.
                Transform.translate(
                  offset: Offset(0, _digitHeight * (1 - slide)),
                  child: _digit(current, style),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _digit(int value, TextStyle style) {
    // Nothing is drawn for a previous total of zero: a leading "0" sliding
    // away would suggest the user had a streak they did not have.
    if (value <= 0) return const SizedBox.shrink();
    return SizedBox(
      height: _digitHeight,
      child: Center(child: Text('$value', style: style)),
    );
  }

  double _digitWidth(BuildContext context, int value, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: '$value', style: style),
      textDirection: Directionality.of(context),
    )..layout();
    return painter.width;
  }
}

/// The snowflake, in the blue the week circles already use for a frozen day.
class _FreezeHero extends StatelessWidget {
  const _FreezeHero();

  @override
  Widget build(BuildContext context) {
    final colour = context.colors.frozenIcon;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.frozenBorder, width: 2),
          color: context.colors.frozenFill,
        ),
        child: Icon(Icons.ac_unit, size: 32, color: colour),
      ),
    );
  }
}
