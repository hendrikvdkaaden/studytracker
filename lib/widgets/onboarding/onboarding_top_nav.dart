import 'package:flutter/material.dart';

class OnboardingTopNav extends StatelessWidget {
  const OnboardingTopNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 42,
          height: 42,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
