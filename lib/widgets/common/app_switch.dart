import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';

/// An on/off switch with the app's own proportions.
///
/// Flutter's own switches have fixed tracks — Cupertino's is 51x31 and not
/// configurable — so a wider, flatter shape means drawing it here. Scaling a
/// built-in switch was tried first and stretches its round knob into an oval.
class AppSwitch extends StatelessWidget {
  static const double _trackWidth = 52;
  static const double _trackHeight = 22;
  static const double _knobWidth = 30;
  static const double _knobHeight = 18;

  /// Leaves 2pt of track visible above and below the knob.
  static const double _inset = (_trackHeight - _knobHeight) / 2;

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
    final trackColor = value ? AppColors.success : context.colors.divider;

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
          color: trackColor,
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
