import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand palette
  static const Color green = Color(0xFF3DBE6E);
  static const Color greenDark = Color(0xFF1E8F4F);
  static const Color greenLight = Color(0xFFEBF9F1);
  static const Color indigo = Color(0xFF5B5BD6);
  static const Color indigoDark = Color(0xFF4040A8);
  static const Color indigoLight = Color(0xFFEEF0FF);
  static const Color amber = Color(0xFFF59E0B);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color gold = Color(0xFFFFB800);

  // Neutral palette
  static const Color bg = Color(0xFFF6F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  // Vibrant UI Colors (Tailwind config)
  static const Color vibrantPrimary = Color(0xFF6B38D4);
  static const Color vibrantSecondary = Color(0xFF735C00);
  static const Color vibrantTertiary = Color(0xFF904800);
  static const Color onVibrantPrimary = Color(0xFFFFFFFF);
  static const Color onVibrantSecondary = Color(0xFFFFFFFF);

  static const Color surfaceContainerHighest = Color(0xFFD9E3F4);
  static const Color primaryFixed = Color(0xFFE9DDFF);
  static const Color primaryFixedDim = Color(0xFFD0BCFF);
  static const Color onPrimaryFixed = Color(0xFF23005C);
  static const Color onPrimaryFixedVariant = Color(0xFF5516BE);
  static const Color primaryContainer = Color(0xFF8455EF);
  
  static const Color secondaryFixed = Color(0xFFFFE083);
  static const Color secondaryFixedDim = Color(0xFFEEC200);
  static const Color secondaryContainer = Color(0xFFFED01B);
  static const Color onSecondaryContainer = Color(0xFF6F5900);
  static const Color onSecondaryFixed = Color(0xFF231B00);
  static const Color onSecondaryFixedVariant = Color(0xFF574500);

  static const Color tertiaryFixed = Color(0xFFFFDCC5);
  static const Color tertiaryFixedDim = Color(0xFFFFB783);
  static const Color tertiaryContainer = Color(0xFFB55D00);
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);
  static const Color onTertiaryFixed = Color(0xFF301400);
  static const Color onTertiaryFixedVariant = Color(0xFF713700);

  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerHigh = Color(0xFFDFE9FA);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerLow = Color(0xFFEEF4FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  
  static const Color outline = Color(0xFF7B7486);
  static const Color outlineVariant = Color(0xFFCBC3D7);
  static const Color inverseSurface = Color(0xFF27313E);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);


  // Legacy aliases (keep backward compat)
  static const Color primaryGreen = green;
  static const Color darkGreen = greenDark;
  static const Color lightGreen = greenLight;
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentYellow = Color(0xFFFFD54F);
  static const Color warmWhite = Color(0xFFFFFDE7);
  static const Color parentBlue = indigo;
  static const Color parentBlueDark = indigoDark;
  static const Color parentBlueLight = indigoLight;
  static const Color childPurple = Color(0xFFAB47BC);
  static const Color textDark = textPrimary;
  static const Color textMedium = textSecondary;
  static const Color textLight = textHint;
  static const Color coinGold = gold;

  // Gradients
  static const LinearGradient gradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4ADE80), Color(0xFF1E8F4F)],
  );

  static const LinearGradient gradientIndigo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF818CF8), Color(0xFF4040A8)],
  );

  static const LinearGradient gradientAmber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
  );

  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3DBE6E), Color(0xFF5B5BD6)],
  );

  // Shadow helpers
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
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static TextTheme _textTheme() {
    return GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textSecondary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, color: textHint),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputTheme(Color focusColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
    );
  }

  static SnackBarThemeData _snackBarTheme() {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
    );
  }

  static ThemeData rootTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.light,
        primary: green,
        secondary: amber,
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: _inputTheme(green),
      snackBarTheme: _snackBarTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        indicatorColor: greenLight,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData parentTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigo,
        brightness: Brightness.light,
        primary: indigo,
        secondary: amber,
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: indigo,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: _inputTheme(indigo),
      snackBarTheme: _snackBarTheme(),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: indigo,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: indigoLight,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData childTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.light,
        primary: green,
        secondary: coral,
        tertiary: amber,
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: _inputTheme(green),
      snackBarTheme: _snackBarTheme(),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: greenLight,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
