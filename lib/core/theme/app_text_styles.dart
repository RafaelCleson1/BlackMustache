import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle display({
    double size = 32,
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 1.2,
    double height = 1.12,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle body({
    double size = 14,
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
    double height = 1.45,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle label({
    double size = 11,
    Color color = AppColors.gold,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 2.4,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sectionTitle() {
    return display(size: 17, letterSpacing: 2.6, weight: FontWeight.w600);
  }

  static TextStyle price({double size = 18}) {
    return body(
      size: size,
      color: AppColors.gold,
      weight: FontWeight.w700,
      letterSpacing: 0.2,
    );
  }
}
