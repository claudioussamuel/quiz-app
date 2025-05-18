import 'package:flutter/material.dart';
import '/utils/theme/custom_theme/app_colors.dart';

class TColorScheme {
  TColorScheme._();

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onSecondary: AppColors.surface,
    onPrimary: AppColors.surface,
    secondary: AppColors.secondary,
    error: Colors.redAccent,
    onError: AppColors.secondary,
    surface: AppColors.surface,
    onSurface: AppColors.text,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onSecondary: AppColors.surfaceDark,
    onPrimary: AppColors.surfaceDark,
    secondary: AppColors.secondaryDark,
    error: Colors.redAccent,
    onError: AppColors.secondaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textDark,
  );
}
