import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';

/// An on/off switch with the app's own proportions.
///
/// Flutter's own switches have fixed tracks — Cupertino's is 51x31 and not
/// configurable — so a wider, flatter shape means drawing it here. Scaling a
/// built-in switch was tried first and stretches its round knob into an oval.
class AppSwitch extends StatelessWidget {
  // Narrowed without lowering, so the switch reads flatter than the iOS one
  // it started from. The knob is narrowed with the track, keeping the 2pt of
  // track showing around it and 18pt of travel between the ends.
  static const double _trackWidth = 52;
  static const double _trackHeight = 22;
  static const double _knobWidth = 30;
  static const double _knobHeight = 18;

  /// Leaves 2pt of track visible above and below the knob.
  static const double _inset = (_trackHeight - _knobHeight) / 2;

  /// Both radii are larger than half of their shortest side, so each shape is
  /// fully rounded. Kept at the values they were specified with rather than
  /// clamped to 14 and 12, since the result is identical and these say what
  /// was asked for.
  static const double _trackRadius = 50;
  static const double _knobRadius = 67;

  final bool value;
  final ValueChanged<bool> onChanged;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      // Taps in the gap between knob and track edge still count.
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: _trackWidth,
        height: _trackHeight,
        decoration: BoxDecoration(
          color: value
              ? AppColors.success
              : (isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(_trackRadius),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _inset),
            child: Container(
              width: _knobWidth,
              height: _knobHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_knobRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
