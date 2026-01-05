import 'package:flutter/material.dart';

/// Application colors
class AppColors {
  // Core Palette
  static const Color primaryAccent = Color(0xFF00FFC2);
  static const Color dangerAccent = Color(0xFFFF2E63);

  // Light Mode Specific
  static const Color lightPrimary = Color(0xFF005E51);
  static const Color lightDanger = Color(0xFFD32F2F);

  // Dark Mode
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Colors.white70;
  static const Color darkGlassBorder = Colors.white10;
  static const Color glassDarkTint = Colors.white;

  // Light Mode
  static const Color lightBackground = Color(0xFFF2F4F7);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF0D1117);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightGlassBorder = Colors.black12;
  static const Color glassLightTint = Colors.black;

  // Chart Colors (Dark)
  static const List<Color> chartColorsDark = [
    Color(0xFF00FFC2),
    Color(0xFFFF2E63),
    Color(0xFF00C3FF),
    Color(0xFFFFD300),
    Color(0xFFB00020),
  ];

  // Chart Colors (Light)
  static const List<Color> chartColorsLight = [
    Color(0xFF00BFA5),
    Color(0xFFD32F2F),
    Color(0xFF0288D1),
    Color(0xFFFBC02D),
    Color(0xFFC2185B),
  ];
}
