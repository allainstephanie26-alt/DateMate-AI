import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DateMate AI design tokens — v4 "premium romantic" redesign.
class AppColors {
  static const coral = Color(0xFFFF7A8A);
  static const coralDeep = Color(0xFFFF5B7A);
  static const magenta = Color(0xFFE6367F);
  static const magentaDeep = Color(0xFFC21E6B);
  static const violet = Color(0xFF8B5CF6);
  static const violetDeep = Color(0xFF6D3FD1);
  static const lavender = Color(0xFFD7C3F7);
  static const lavenderSoft = Color(0xFFEDE1FB);

  static const primary = magentaDeep;
  static const primaryDark = Color(0xFF3B1240);
  static const gradientEnd = magenta;
  static const secondary = violet;
  static const rose = coral;
  static const blush = Color(0xFFFBEAF2);
  static const blushDeep = Color(0xFFF5D8E8);
  static const peach = Color(0xFFFFD3B6);
  static const tertiary = peach;
  static const gold = Color(0xFFE8A639);

  static const background = Color(0xFFFCF7FD);
  static const surface = Colors.white;
  static const card = Colors.white;
  static const onSurface = Color(0xFF2B1130);
  static const ink = onSurface;
  static const muted = Color(0xFF8D7693);
  static const onSurfaceVariant = muted;
  static const outline = Color(0xFFF0DFF0);
  static const outlineSoft = Color(0xFFF6ECF8);

  static const success = Color(0xFF3F9A63);
  static const successBg = Color(0xFFE7F5EB);
  static const error = Color(0xFFD23A5E);
  static const warning = Color(0xFFB77A35);
  static const darkSurface = Color(0xFF3B1240);

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [coralDeep, magenta, violetDeep],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coral, magentaDeep, Color(0xFF4A1766)],
  );

  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF1F4), Color(0xFFFBF3FE)],
  );

  static const glowGradient = RadialGradient(
    colors: [Color(0x55FF7A8A), Color(0x00FF7A8A)],
  );

  static const shimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8E0EC), Color(0xFFFCEFF8), Color(0xFFF8E0EC)],
  );

  static const chipGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFE3EA), Color(0xFFF2E4FC)],
  );

  static const placeGradients = <List<Color>>[
    [Color(0xFFFF9A8B), Color(0xFFE6367F), Color(0xFF6D3FD1)],
    [Color(0xFFFFC371), Color(0xFFFF5B7A), Color(0xFF8B5CF6)],
    [Color(0xFF8FD3C9), Color(0xFF6D83F2), Color(0xFF8B5CF6)],
    [Color(0xFFFFB6C9), Color(0xFFC94B9A), Color(0xFF5B2C8A)],
    [Color(0xFFFFD36E), Color(0xFFEF6C9B), Color(0xFF7A4FD1)],
    [Color(0xFF9BE8D8), Color(0xFF5FB8E8), Color(0xFF7C5CE0)],
    [Color(0xFFFFA3A3), Color(0xFFE6367F), Color(0xFF4A1766)],
    [Color(0xFFB8A2FF), Color(0xFF8B5CF6), Color(0xFF4F2FA8)],
    [Color(0xFFFFCE9E), Color(0xFFFF6F91), Color(0xFF6D3FD1)],
    [Color(0xFF9FD8FF), Color(0xFFA78BFA), Color(0xFFE6367F)],
  ];
}

class AppRadius {
  static const small = 14.0;
  static const medium = 18.0;
  static const card = 26.0;
  static const large = 32.0;
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
    BoxShadow(color: Color(0x14C21E6B), blurRadius: 26, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const soft = <BoxShadow>[
    BoxShadow(color: Color(0x1AC21E6B), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const floating = <BoxShadow>[
    BoxShadow(color: Color(0x33C21E6B), blurRadius: 32, offset: Offset(0, 16)),
  ];

  static const glow = <BoxShadow>[
    BoxShadow(color: Color(0x40E6367F), blurRadius: 22, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x308B5CF6), blurRadius: 10, offset: Offset(0, 2)),
  ];
}

class GlassLayer extends StatelessWidget {
  const GlassLayer({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.card,
    this.blur = 18,
    this.tint = Colors.white,
    this.opacity = .72,
    this.borderOpacity = .55,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final Color tint;
  final double opacity;
  final double borderOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: tint.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

final _baseTextTheme = GoogleFonts.urbanistTextTheme();

final appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: GoogleFonts.urbanist().fontFamily,
  visualDensity: VisualDensity.standard,
  splashFactory: InkRipple.splashFactory,

  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.magenta).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.violet,
    tertiary: AppColors.coral,
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

  textTheme: _baseTextTheme.copyWith(
    displaySmall: GoogleFonts.urbanist(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
      height: 1.08,
      letterSpacing: -0.4,
    ),
    headlineSmall: GoogleFonts.urbanist(
      fontSize: 25,
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
      height: 1.1,
      letterSpacing: -0.3,
    ),
    titleLarge: GoogleFonts.urbanist(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
      height: 1.15,
      letterSpacing: -0.2,
    ),
    titleMedium: GoogleFonts.urbanist(
      fontSize: 15.5,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      height: 1.2,
    ),
    bodyLarge: GoogleFonts.urbanist(
      fontSize: 15.5,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
      height: 1.48,
    ),
    bodyMedium: GoogleFonts.urbanist(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
      height: 1.44,
    ),
    bodySmall: GoogleFonts.urbanist(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.muted,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.urbanist(
      fontSize: 13.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.urbanist(
      fontSize: 12,
      fontWeight: FontWeight.w800,
    ),
    labelSmall: GoogleFonts.urbanist(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.muted,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
    prefixIconColor: AppColors.magenta,
    suffixIconColor: AppColors.muted,
    hintStyle: GoogleFonts.urbanist(
      color: const Color(0xFFBFA4C4),
      fontSize: 13.5,
    ),
    labelStyle: GoogleFonts.urbanist(color: AppColors.muted, fontSize: 12.5),
    helperStyle: GoogleFonts.urbanist(color: AppColors.muted, fontSize: 11),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.outline, width: 1.4),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.outline, width: 1.4),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.magenta, width: 1.8),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.error, width: 1.4),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.error, width: 1.8),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: AppColors.magenta,
    side: const BorderSide(color: AppColors.outline, width: 1.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    labelStyle: GoogleFonts.urbanist(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    ),
    secondaryLabelStyle: GoogleFonts.urbanist(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
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
      backgroundColor: AppColors.magentaDeep,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      textStyle: GoogleFonts.urbanist(
        fontWeight: FontWeight.w800,
        fontSize: 13.5,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(0, 48),
      side: const BorderSide(color: AppColors.outline, width: 1.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      textStyle: GoogleFonts.urbanist(
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.magenta,
      textStyle: GoogleFonts.urbanist(
        fontWeight: FontWeight.w800,
        fontSize: 12.5,
      ),
    ),
  ),

  dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 1),

  splashColor: Color(0x26E6367F),
  highlightColor: Color(0x12E6367F),
);
