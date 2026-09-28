import 'package:flutter/material.dart';

class AppColors {
  // Palette intentionally stays close to the original mockups:
  // deep wine + rose + blush + warm ivory, with restrained green for success.
  static const primary = Color(0xFF64172F);
  static const primaryDark = Color(0xFF431020);
  static const gradientEnd = Color(0xFFD6427D);
  static const secondary = gradientEnd;
  static const rose = Color(0xFFF29BB7);
  static const blush = Color(0xFFFCE5EC);
  static const blushDeep = Color(0xFFF7D0DC);
  static const background = Color(0xFFFFF8F5);
  static const surface = Colors.white;
  static const card = Colors.white;
  static const onSurface = Color(0xFF291720);
  static const ink = onSurface;
  static const muted = Color(0xFF8B6672);
  static const onSurfaceVariant = muted;
  static const outline = Color(0xFFE7C5D0);
  static const peach = Color(0xFFF8C7B8);
  static const tertiary = peach;
  static const success = Color(0xFF79A889);
  static const error = Color(0xFFB3261E);
  static const warning = Color(0xFFB77A35);
  static const darkSurface = Color(0xFF4E1426);

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

  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFEEF3), Color(0xFFFFF8F5)],
  );
}

class AppRadius {
  static const small = 12.0;
  static const medium = 16.0;
  static const card = 22.0;
  static const large = 28.0;
  static const pill = 999.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 7)),
  ];

  static const soft = <BoxShadow>[
    BoxShadow(color: Color(0x0F64172F), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

final appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Roboto',
  visualDensity: VisualDensity.standard,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.gradientEnd,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    error: AppColors.error,
    outline: AppColors.outline,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.primary,
    elevation: 0,
    centerTitle: false,
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 31,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      height: 1.05,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 25,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      height: 1.08,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      height: 1.12,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
      height: 1.2,
    ),
    bodyLarge: TextStyle(fontSize: 15, color: AppColors.ink, height: 1.45),
    bodyMedium: TextStyle(fontSize: 13.5, color: AppColors.ink, height: 1.42),
    bodySmall: TextStyle(fontSize: 11.5, color: AppColors.muted, height: 1.35),
    labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    labelMedium: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
    labelSmall: TextStyle(fontSize: 10.5, color: AppColors.muted),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    prefixIconColor: AppColors.gradientEnd,
    suffixIconColor: AppColors.muted,
    hintStyle: const TextStyle(color: Color(0xFFB49AA3), fontSize: 13),
    labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
    helperStyle: const TextStyle(color: AppColors.muted, fontSize: 10.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.gradientEnd, width: 1.7),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.error, width: 1.7),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: AppColors.primary,
    side: const BorderSide(color: AppColors.outline),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    labelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: const BorderSide(color: AppColors.outline),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(0, 46),
      side: const BorderSide(color: AppColors.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.gradientEnd,
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 1),
);
