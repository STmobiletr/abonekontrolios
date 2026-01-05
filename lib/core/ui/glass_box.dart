import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget that creates a glassmorphism effect
class GlassBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color color;
  final double blur;
  final Color? borderColor;
  final double? gradientOpacity;

  const GlassBox({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.color = Colors.white,
    this.blur = 20,
    this.borderColor,
    this.gradientOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(gradientOpacity ?? 0.1),
                  color.withOpacity(gradientOpacity ?? 0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
