import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  const colorScheme = ColorScheme.dark(
    primary: AppColors.gold,
    onPrimary: AppColors.ink,
    secondary: AppColors.goldSoft,
    onSecondary: AppColors.ink,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
    onError: AppColors.ink,
    outline: AppColors.border,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    dividerColor: AppColors.border,
    splashColor: AppColors.gold.withValues(alpha: 0.08),
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.display(size: 17, letterSpacing: 3.2),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.gold,
      linearTrackColor: AppColors.border,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: AppTextStyles.body(size: 13),
      behavior: SnackBarBehavior.floating,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.textMuted,
      selectedLabelStyle: AppTextStyles.body(
        size: 11,
        weight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: AppTextStyles.body(
        size: 11,
        color: AppColors.textMuted,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
