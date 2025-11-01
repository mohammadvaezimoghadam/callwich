import 'package:callwich/components/text_styles.dart';
import 'package:callwich/res/colors.dart';
import 'package:flutter/material.dart';

ThemeData themeData() {
  return ThemeData(
    textTheme: textTheme(),
    dividerColor: Color(0xFFe7d9cf),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: LightAppColors.primary,
      onPrimary: LightAppColors.onPrimary,
      secondary: LightAppColors.secondary,
      onSecondary: LightAppColors.onSecondary,
      error: LightAppColors.textError,
      onError: LightAppColors.onPrimary,
      surface: LightAppColors.surface,
      onSurface: LightAppColors.onSurface,
      primaryContainer: LightAppColors.primaryContainer,
      onPrimaryContainer: LightAppColors.onPrimaryContainer,
      surfaceContainerHigh: LightAppColors.surfaceVariant,
      onSurfaceVariant: LightAppColors.onSurfaceVariant,
      outline: Color(0xFFE5E7EB),
    ),
  );
}
