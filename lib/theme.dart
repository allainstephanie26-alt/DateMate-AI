import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DateMate AI design tokens — v5 "dark romantic" theme.
///
/// Token NAMES are unchanged from v4 so every screen keeps compiling; only
/// their values moved to a deep plum / dark violet / near-black palette with
/// pink, coral, magenta, lavender and purple accents.
///
/// Reading guide:
///  * [primary] is the main TEXT/title colour (a soft near-white blush) —
///    it is no longer a fill colour. Fills use [magentaDeep] / gradients.
///  * [blush] / [blushDeep] / [lavenderSoft] are now dark tinted tiles used
///    behind small icons and chips.
class AppColors {
  // ── Accent family (unchanged hues, tuned to sit on dark surfaces) ──────
  static const coral = Color(0xFFFF7A8A);
  static const coralDeep = Color(0xFFFF5B7A);
  static const magenta = Color(0xFFE6367F);
  static const magentaDeep = Color(0xFFC21E6B);
  static const violet = Color(0xFF8B5CF6);
  static const violetDeep = Color(0xFF6D3FD1);
  static const lavender = Color(0xFFD7C3F7);
  static const lavenderSoft = Color(0xFF2A1A44);

  // Readable accent tints for TEXT on dark surfaces.
  static const pinkText = Color(0xFFFF8FB1);
  static const lavenderText = Color(0xFFC9B3F5);

  // ── Text ──────────────────────────────────────────────────────────────
  static const primary = Color(0xFFF8EEFB); // titles / strong text
  static const primaryDark = Color(0xFF12081A); // deepest plum (overlays)
  static const onSurface = Color(0xFFF3E8F7);
  static const ink = onSurface;
  static const muted = Color(0xFFB9A5C6);
  static const onSurfaceVariant = muted;

  // ── Accents used as fills ─────────────────────────────────────────────
  static const gradientEnd = magenta;
  static const secondary = violet;
  static const rose = coral;
  static const peach = Color(0xFFFFB690);
  static const tertiary = peach;
  static const gold = Color(0xFFF0B24A);

  // ── Surfaces ──────────────────────────────────────────────────────────
  static const backgroundDeep = Color(0xFF08050D);
  static const background = Color(0xFF0E0914);
  static const surface = Color(0xFF1A1124);
  static const surfaceHigh = Color(0xFF241632);
  static const surfaceTop = Color(0xFF2C1A3C);
  static const card = surface;
  static const blush = Color(0xFF2E1A3B);
  static const blushDeep = Color(0xFF45244F);
  static const outline = Color(0xFF3A2849);
  static const outlineSoft = Color(0xFF2A1B38);
  static const darkSurface = Color(0xFF12081A);

  // ── Status ────────────────────────────────────────────────────────────
  static const success = Color(0xFF5BC98A);
  static const successBg = Color(0xFF16301F);
  static const error = Color(0xFFFF6B8B);
  static const warning = Color(0xFFE0A15A);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [coralDeep, magenta, violetDeep],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD9476F), Color(0xFF8E1F63), Color(0xFF2A1048)],
  );

  /// Layered card fill: a barely-lit violet top edge fading into plum.
  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2B1737), Color(0xFF1B1228)],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF241633), Color(0xFF181022)],
  );

  static const glowGradient = RadialGradient(
    colors: [Color(0x55FF7A8A), Color(0x00FF7A8A)],
  );

  static const shimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF241633), Color(0xFF331E45), Color(0xFF241633)],
  );

  static const chipGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3A1C3F), Color(0xFF2A1A4A)],
  );

  static const placeGradients = <List<Color>>[
    [Color(0xFFB8506A), Color(0xFF8E1F63), Color(0xFF3A1A6A)],
    [Color(0xFFB8744A), Color(0xFFB03A5A), Color(0xFF4F2A8A)],
    [Color(0xFF3F8F86), Color(0xFF4A58B0), Color(0xFF4F2A8A)],
    [Color(0xFFB0506E), Color(0xFF8A3A78), Color(0xFF3A1D5E)],
    [Color(0xFFB89040), Color(0xFFA84A78), Color(0xFF4F3290)],
    [Color(0xFF3F9A88), Color(0xFF3F7FA8), Color(0xFF4A3A9A)],
    [Color(0xFFB04A5A), Color(0xFF8E1F63), Color(0xFF2A1048)],
    [Color(0xFF6A56B8), Color(0xFF5A3AB0), Color(0xFF2F1D6A)],
    [Color(0xFFB87A58), Color(0xFFB03A62), Color(0xFF4A2A8A)],
    [Color(0xFF5A86B8), Color(0xFF6A56B8), Color(0xFF8E1F63)],
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
    BoxShadow(color: Color(0x66000000), blurRadius: 26, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x14E6367F), blurRadius: 30, offset: Offset(0, 4)),
  ];

  static const soft = <BoxShadow>[
    BoxShadow(color: Color(0x4D000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const floating = <BoxShadow>[
    BoxShadow(color: Color(0x99000000), blurRadius: 32, offset: Offset(0, 14)),
    BoxShadow(color: Color(0x1F8B5CF6), blurRadius: 36, offset: Offset(0, 0)),
  ];

  static const glow = <BoxShadow>[
    BoxShadow(color: Color(0x4DE6367F), blurRadius: 22, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x388B5CF6), blurRadius: 12, offset: Offset(0, 2)),
  ];
}

/// Frosted dark glass: a translucent plum tint over a blurred backdrop with
/// a hairline light border.
class GlassLayer extends StatelessWidget {
  const GlassLayer({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.card,
    this.blur = 18,
    this.tint = const Color(0xFF2A1838),
    this.opacity = .62,
    this.borderOpacity = .12,
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

/// App-wide page background: near-black plum with soft magenta / violet
/// light pools. Screens use transparent Scaffolds so this shows through.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF160C20),
                AppColors.background,
                AppColors.backgroundDeep,
              ],
            ),
          ),
        ),
        Positioned(
          top: -140,
          right: -120,
          child: _pool(380, const Color(0xFFE6367F), .17),
        ),
        Positioned(
          top: 260,
          left: -190,
          child: _pool(380, const Color(0xFF8B5CF6), .13),
        ),
        Positioned(
          bottom: -170,
          right: -130,
          child: _pool(340, const Color(0xFFFF7A8A), .08),
        ),
        child,
      ],
    );
  }

  static Widget _pool(double size, Color color, double alpha) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        ),
      ),
    ),
  );
}

final _baseTextTheme = GoogleFonts.urbanistTextTheme(
  ThemeData(brightness: Brightness.dark).textTheme,
);

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  canvasColor: AppColors.surface,
  fontFamily: GoogleFonts.urbanist().fontFamily,
  visualDensity: VisualDensity.standard,
  splashFactory: InkRipple.splashFactory,

  colorScheme: const ColorScheme.dark(
    primary: AppColors.magenta,
    onPrimary: Colors.white,
    secondary: AppColors.violet,
    onSecondary: Colors.white,
    tertiary: AppColors.coral,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.muted,
    error: AppColors.error,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineSoft,
    surfaceContainerHighest: AppColors.surfaceHigh,
  ),

  iconTheme: const IconThemeData(color: AppColors.lavender),

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
    fillColor: const Color(0xFF211530),
    contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
    prefixIconColor: AppColors.pinkText,
    suffixIconColor: AppColors.muted,
    hintStyle: GoogleFonts.urbanist(
      color: const Color(0xFF9B87A8),
      fontSize: 13.5,
    ),
    labelStyle: GoogleFonts.urbanist(color: AppColors.muted, fontSize: 12.5),
    floatingLabelStyle: GoogleFonts.urbanist(
      color: AppColors.pinkText,
      fontSize: 12.5,
    ),
    helperStyle: GoogleFonts.urbanist(color: AppColors.muted, fontSize: 11),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.outline, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.outline, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.coral, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.error, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: const BorderSide(color: AppColors.error, width: 1.6),
    ),
  ),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppColors.coral,
    selectionColor: Color(0x55E6367F),
    selectionHandleColor: AppColors.coral,
  ),

  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceHigh,
    selectedColor: AppColors.magentaDeep,
    side: const BorderSide(color: AppColors.outline, width: 1.2),
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
    color: AppColors.surface,
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
      disabledBackgroundColor: const Color(0xFF3A2B47),
      disabledForegroundColor: const Color(0xFF8F7CA0),
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
      disabledForegroundColor: const Color(0xFF7D6A8C),
      backgroundColor: Colors.white.withValues(alpha: .04),
      minimumSize: const Size(0, 48),
      side: BorderSide(
        color: AppColors.pinkText.withValues(alpha: .38),
        width: 1.2,
      ),
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
      foregroundColor: AppColors.pinkText,
      textStyle: GoogleFonts.urbanist(
        fontWeight: FontWeight.w800,
        fontSize: 12.5,
      ),
    ),
  ),

  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: AppColors.lavender),
  ),

  dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 1),

  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surfaceHigh,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: BorderSide(color: Colors.white.withValues(alpha: .10)),
    ),
    titleTextStyle: GoogleFonts.urbanist(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
    ),
    contentTextStyle: GoogleFonts.urbanist(
      fontSize: 13.5,
      color: AppColors.ink,
      height: 1.4,
    ),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: Colors.transparent,
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFF33203F),
    contentTextStyle: GoogleFonts.urbanist(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
    actionTextColor: AppColors.pinkText,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withValues(alpha: .10)),
    ),
  ),

  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppColors.magenta
          : Colors.transparent,
    ),
    checkColor: const WidgetStatePropertyAll(Colors.white),
    side: const BorderSide(color: AppColors.muted, width: 1.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.coral,
    circularTrackColor: Color(0x22FFFFFF),
  ),

  splashColor: const Color(0x26E6367F),
  highlightColor: const Color(0x12E6367F),
);