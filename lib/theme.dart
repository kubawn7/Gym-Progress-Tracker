import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF18181C);
  static const Color surfaceHigh = Color(0xFF222228);
  static const Color accent = Color(0xFFE8FF47);
  static const Color accentDim = Color(0xFF9AAA1E);
  static const Color text = Color(0xFFF5F5F0);
  static const Color textMid = Color(0xFF9A9A90);
  static const Color textLow = Color(0xFF55554E);
  static const Color danger = Color(0xFFFF4747);
  static const Color success = Color(0xFF47FF8C);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          background: bg,
          surface: surface,
          primary: accent,
          secondary: accentDim,
          error: danger,
          onBackground: text,
          onSurface: text,
          onPrimary: bg,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: text, displayColor: text),
        appBarTheme: AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            color: text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          iconTheme: const IconThemeData(color: text),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textLow,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: bg,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          labelStyle: const TextStyle(color: textMid),
          hintStyle: const TextStyle(color: textLow),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: surfaceHigh,
          thickness: 1,
        ),
        useMaterial3: true,
      );
}
