import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF64172F);
  static const primaryDark = Color(0xFF431020);
  static const gradientEnd = Color(0xFFD6427D);
  static const rose = Color(0xFFF29BB7);
  static const blush = Color(0xFFFCE5EC);
  static const secondary = blush;
  static const background = Color(0xFFFFF8F5);
  static const surface = Colors.white;
  static const onSurface = Color(0xFF291720);
  static const ink = onSurface;
  static const muted = Color(0xFF8B6672);
  static const onSurfaceVariant = muted;
  static const outline = Color(0xFFE8C4CF);
  static const peach = Color(0xFFF8C7B8);
  static const tertiary = peach;
  static const success = Color(0xFF8EBB9A);
  static const error = Color(0xFFB3261E);

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientEnd, primary],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE04D84), Color(0xFF64172F)],
  );

  static const heroCardGradient = heroGradient;

  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFEEF3), Color(0xFFFFF8F5)],
  );
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

final appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Arial',
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.gradientEnd,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    error: AppColors.error,
    outline: AppColors.outline,
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    ),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.ink),
    labelSmall: TextStyle(fontSize: 11, color: AppColors.muted),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    prefixIconColor: AppColors.gradientEnd,
    suffixIconColor: AppColors.muted,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: AppColors.gradientEnd, width: 1.5),
    ),
  ),
);
