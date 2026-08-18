import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_system.dart';

class QuestlyTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ColorSystem.cream,
      primaryColor: ColorSystem.purple,
      colorScheme: const ColorScheme.light(
        primary: ColorSystem.purple,
        secondary: ColorSystem.lavender,
        surface: ColorSystem.cream,
        background: ColorSystem.cream,
        error: ColorSystem.pink,
        onPrimary: Colors.white,
        onSecondary: ColorSystem.plum,
        onSurface: ColorSystem.plum,
      ),
      // Fredoka game-like typography configurations
      textTheme: GoogleFonts.fredokaTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: ColorSystem.plum,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: ColorSystem.plum,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum,
          ),
        ),
      ),
      // Clean geometric Input fields styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorSystem.plum, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorSystem.plum, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorSystem.purple, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorSystem.pink, width: 2),
        ),
        labelStyle: const TextStyle(color: ColorSystem.plum, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: ColorSystem.plum.withOpacity(0.5)),
      ),
      // Selectively applied thick borders for specific UI containers
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ColorSystem.plum, width: 1.5),
        ),
      ),
    );
  }
}
