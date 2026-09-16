import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

BoxDecoration onboardingCardDecoration(BuildContext context) {
  return BoxDecoration(
    color: context.colors.card,
    borderRadius: BorderRadius.circular(24),
    border: context.colors.cardOutline(),
    boxShadow: context.colors.cardShadow(),
  );
}
