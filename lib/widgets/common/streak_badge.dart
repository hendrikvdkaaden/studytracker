import 'package:flutter/material.dart';

import '../../theme/app_theme_extension.dart';

/// Flame plus day count for the current study streak.
///
/// Shared rather than inlined: the streak now appears on both the home screen
/// and the consistency card, and a second hand-rolled copy would drift on
/// threshold, colour and size.
///
/// An icon, not the 🔥 emoji it replaces. The emoji cannot be tinted, ignores
/// the chosen accent and renders differently per platform -- all of which show
/// once it is displayed at any size.
class StreakBadge extends StatelessWidget {
  final int streak;

  /// Height of the flame; the number follows it.
  final double size;

  const StreakBadge({
    super.key,
    required this.streak,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    // Nothing at zero. Shown from day one otherwise: hiding it until day two
    // kept it from the users who most need the encouragement, but an empty
    // box at zero would make the row jump as the streak comes and goes.
    if (streak <= 0) return const SizedBox.shrink();

    final colour = context.colors.streakFlame;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department, size: size, color: colour),
        const SizedBox(width: 2),
        Text(
          '$streak',
          style: TextStyle(
            fontSize: size - 3,
            fontWeight: FontWeight.bold,
            color: colour,
          ),
        ),
      ],
    );
  }
}
