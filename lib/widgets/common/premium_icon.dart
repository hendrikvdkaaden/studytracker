import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PremiumIcon extends StatelessWidget {
  const PremiumIcon({super.key, this.size = 96});

  /// Overall bounding box. Diamond container scales to 2/3 of this.
  final double size;

  @override
  Widget build(BuildContext context) {
    final boxSize = size * (2 / 3);
    final radius = boxSize * 0.28;
    final iconSize = boxSize * 0.53;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.premiumBlue, AppColors.premiumDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.premiumBlue.withValues(alpha: 0.3),
                  blurRadius: size * 0.17,
                  offset: Offset(0, size * 0.06),
                ),
              ],
            ),
            child: Icon(Icons.diamond_outlined, color: Colors.white, size: iconSize),
          ),
          Positioned(
            top: 0,
            right: size * 0.02,
            child: Icon(Icons.auto_awesome, color: AppColors.premiumBlue, size: size * 0.21),
          ),
          Positioned(
            top: size * 0.06,
            left: 0,
            child: Icon(Icons.star, color: AppColors.premiumGradientEnd.withValues(alpha: 0.7), size: size * 0.15),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(Icons.star, color: AppColors.premiumBlue.withValues(alpha: 0.5), size: size * 0.15),
          ),
          Positioned(
            bottom: size * 0.04,
            left: size * 0.02,
            child: Icon(Icons.auto_awesome, color: AppColors.premiumBlue.withValues(alpha: 0.4), size: size * 0.10),
          ),
        ],
      ),
    );
  }
}
