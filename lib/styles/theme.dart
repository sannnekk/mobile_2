import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static final lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    brightness: Brightness.light,
    surface: AppColors.lightest,
    onSurface: AppColors.dark,
    error: AppColors.danger,
    onError: AppColors.lightest,
  );

  static final darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppDarkColors.primary,
    primary: AppDarkColors.primary,
    secondary: AppDarkColors.secondary,
    brightness: Brightness.dark,
    surface: AppDarkColors.lightest,
    onSurface: AppDarkColors.textColor,
    error: AppDarkColors.danger,
    onError: AppDarkColors.lightest,
  );

  static ThemeData lightTheme = ThemeData(
    colorScheme: lightColorScheme,
    useMaterial3: true,
    fontFamily: 'Montserrat',
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.formBackground,
    cardColor: AppColors.formBackground,
    dividerColor: AppColors.borderColor,
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: darkColorScheme,
    useMaterial3: true,
    fontFamily: 'Montserrat',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppDarkColors.lightBackgroundColor,
    cardColor: AppDarkColors.formBackground,
    dividerColor: AppDarkColors.borderColor,
  );
}
