import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final List<Color> gradientColors;
  final Color borderColor;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.borderRadius,
    this.gradientColors = const [Colors.white, Colors.white],
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientColors.first.withAlpha(102), // 0.4 opacity = ~102 alpha
                gradientColors.last.withAlpha(38), // 0.15 opacity = ~38 alpha
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
