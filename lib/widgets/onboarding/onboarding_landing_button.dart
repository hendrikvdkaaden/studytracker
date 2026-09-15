import 'package:flutter/material.dart';

import '../../theme/app_theme_extension.dart';

class OnboardingLandingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double? width;

  const OnboardingLandingButton({
    super.key,
    required this.label,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Was a hardcoded teal gradient, which stayed teal whatever accent the
    // user picked -- most visible in onboarding, on a faintly tinted page.
    // The glow has to track it too, or a pink button casts a teal shadow.
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.accent, colors.accentStrong],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.accentStrong.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            width: width ?? 280,
            height: 62,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
