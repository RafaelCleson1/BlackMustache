import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0E0E0E);
  static const backgroundAlt = Color(0xFF121212);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceElevated = Color(0xFF1E1E1E);
  static const border = Color(0xFF2C2C2C);

  static const gold = Color(0xFFD4AF37);
  static const goldSoft = Color(0xFFC9A66B);
  static const goldLight = Color(0xFFE8D48A);
  static const goldDim = Color(0xFF8A7229);

  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF9E9E9E);
  static const textMuted = Color(0xFF6B6B6B);

  static const danger = Color(0xFFE0785F);
  static const ink = Color(0xFF141414);

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldSoft],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xD90E0E0E)],
    stops: [0.35, 1],
  );
}
