import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GrowWise · Playful Modernism theme.
/// Constant NAMES are kept for backward-compat across all screens; their
/// VALUES are repointed to the new warm orange/cream design system.
class AppTheme {
  // Brand palette
  static const Color green = Color(0xFF22A45A); // success / secondary green
  static const Color greenDark = Color(0xFF0C7A3D);
  static const Color greenLight = Color(0xFFE4F8EA);
  static const Color indigo = Color(0xFF6833EA); // now purple (parent accent)
  static const Color indigoDark = Color(0xFF4600BB);
  static const Color indigoLight = Color(0xFFE8DEFF);
  static const Color amber = Color(0xFFFFB300);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color gold = Color(0xFFFFB800);

  // Neutral palette (warm cream)
  static const Color bg = Color(0xFFFFF8F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF211B10);
  static const Color textSecondary = Color(0xFF564334);
  static const Color textHint = Color(0xFF8B7765);
  static const Color border = Color(0xFFDDC1AE);

  // Vibrant UI colors — brand accent is now ORANGE
  static const Color vibrantPrimary = Color(0xFFFF8C00);
  static const Color vibrantSecondary = Color(0xFF006E1C);
  static const Color vibrantTertiary = Color(0xFF6833EA);
  static const Color onVibrantPrimary = Color(0xFF4A2600);
  static const Color onVibrantSecondary = Color(0xFFFFFFFF);

  static const Color surfaceContainerHighest = Color(0xFFEEE1CF);
  static const Color primaryFixed = Color(0xFFFFDCC3);
  static const Color primaryFixedDim = Color(0xFFFFB77D);
  static const Color onPrimaryFixed = Color(0xFF311300);
  static const Color onPrimaryFixedVariant = Color(0xFF6E3A00);
  static const Color primaryContainer = Color(0xFFFF8C00);

  static const Color secondaryFixed = Color(0xFF96F592);
  static const Color secondaryFixedDim = Color(0xFF7EDB7B);
  static const Color secondaryContainer = Color(0xFF96F592);
  static const Color onSecondaryContainer = Color(0xFF00531A);
  static const Color onSecondaryFixed = Color(0xFF002204);
  static const Color onSecondaryFixedVariant = Color(0xFF00531A);

  static const Color tertiaryFixed = Color(0xFFE8DEFF);
  static const Color tertiaryFixedDim = Color(0xFFB29BFF);
  static const Color tertiaryContainer = Color(0xFF6833EA);
  static const Color onTertiaryContainer = Color(0xFFFFFFFF);
  static const Color onTertiaryFixed = Color(0xFF21005D);
  static const Color onTertiaryFixedVariant = Color(0xFF4600BB);

  static const Color surfaceBright = Color(0xFFFFF8F2);
  static const Color surfaceContainerHigh = Color(0xFFF3E6D4);
  static const Color surfaceContainer = Color(0xFFF9ECDA);
  static const Color surfaceContainerLow = Color(0xFFFFF2E0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  static const Color outline = Color(0xFF897362);
  static const Color outlineVariant = Color(0xFFDDC1AE);
  static const Color inverseSurface = Color(0xFF362F22);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Legacy aliases (keep backward compat)
  static const Color primaryGreen = green;
  static const Color darkGreen = greenDark;
  static const Color lightGreen = greenLight;
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color accentYellow = Color(0xFFFFD54F);
  static const Color warmWhite = Color(0xFFFFF8F2);
  static const Color parentBlue = indigo;
  static const Color parentBlueDark = indigoDark;
  static const Color parentBlueLight = indigoLight;
  static const Color childPurple = Color(0xFF6833EA);
  static const Color textDark = textPrimary;
  static const Color textMedium = textSecondary;
  static const Color textLight = textHint;
  static const Color coinGold = gold;

  // Radii (Playful Modernism)
  static const double rInput = 16;
  static const double rCard = 24;

  // Gradients
  static const LinearGradient gradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7EDB7B), Color(0xFF006E1C)],
  );

  static const LinearGradient gradientIndigo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B7BFF), Color(0xFF6833EA)],
  );

  static const LinearGradient gradientAmber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB454), Color(0xFFFF8C00)],
  );

  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB454), Color(0xFF904D00)],
  );

  // Shadow helpers — soft warm shadow
  static List<BoxShadow> shadowSm(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.12),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> shadowLg(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.18),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF784614).withValues(alpha: 0.18),
      blurRadius: 22,
      offset: const Offset(0, 8),
    ),
  ];

  static TextTheme _textTheme() {
    return GoogleFonts.nunitoSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textSecondary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, color: textHint),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textSecondary,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputTheme(Color focusColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rInput),
        borderSide: const BorderSide(color: outlineVariant, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rInput),
        borderSide: const BorderSide(color: outlineVariant, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rInput),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rInput),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rInput),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFFB6A48C), fontSize: 15, fontWeight: FontWeight.w600),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
    );
  }

  static SnackBarThemeData _snackBarTheme() {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rInput)),
      elevation: 4,
    );
  }

  // Pill buttons (StadiumBorder) — the signature tactile shape.
  static ButtonStyle _pillFilled(Color bg, Color fg) => FilledButton.styleFrom(
    backgroundColor: bg,
    foregroundColor: fg,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
    textStyle: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w800),
  );

  static CardThemeData _cardTheme() => CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rCard)),
    color: surface,
  );

  static AppBarTheme _appBarTheme() => AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: textPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.nunitoSans(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: vibrantPrimary,
    ),
  );

  static NavigationBarThemeData _navTheme() => NavigationBarThemeData(
    backgroundColor: surface,
    elevation: 0,
    indicatorColor: primaryFixed,
    labelTextStyle: WidgetStateProperty.all(
      GoogleFonts.nunitoSans(fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );

  static ThemeData rootTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vibrantPrimary,
        brightness: Brightness.light,
        primary: vibrantPrimary,
        onPrimary: onVibrantPrimary,
        secondary: vibrantSecondary,
        tertiary: vibrantTertiary,
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(),
      appBarTheme: _appBarTheme(),
      inputDecorationTheme: _inputTheme(vibrantPrimary),
      snackBarTheme: _snackBarTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _pillFilled(vibrantPrimary, onVibrantPrimary),
      ),
      cardTheme: _cardTheme(),
      navigationBarTheme: _navTheme(),
    );
  }

  static ThemeData parentTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigo,
        brightness: Brightness.light,
        primary: indigo,
        onPrimary: Colors.white,
        secondary: vibrantPrimary,
        tertiary: vibrantSecondary,
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(),
      appBarTheme: _appBarTheme(),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: indigo,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: _inputTheme(indigo),
      snackBarTheme: _snackBarTheme(),
      filledButtonTheme: FilledButtonThemeData(
        style: _pillFilled(indigo, Colors.white),
      ),
      cardTheme: _cardTheme(),
      navigationBarTheme: _navTheme().copyWith(indicatorColor: indigoLight),
    );
  }

  static ThemeData childTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vibrantPrimary,
        brightness: Brightness.light,
        primary: vibrantPrimary,
        onPrimary: onVibrantPrimary,
        secondary: vibrantSecondary,
        tertiary: vibrantTertiary,
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(),
      appBarTheme: _appBarTheme(),
      inputDecorationTheme: _inputTheme(vibrantPrimary),
      snackBarTheme: _snackBarTheme(),
      filledButtonTheme: FilledButtonThemeData(
        style: _pillFilled(vibrantPrimary, onVibrantPrimary),
      ),
      cardTheme: _cardTheme(),
      navigationBarTheme: _navTheme(),
    );
  }
}
