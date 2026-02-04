import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE6E6FA),
        brightness: Brightness.light,
        primary: const Color(0xFFE6E6FA),
        secondary: const Color(0xFFF8B4D9),
        tertiary: const Color(0xFFB4D8F8),
        surface: const Color(0xFFFFFAFA),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFAFA),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSansKR(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4A4A6A),
        ),
        displayMedium: GoogleFonts.notoSansKR(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5A5A7A),
        ),
        bodyLarge: GoogleFonts.notoSansKR(
          fontSize: 16,
          color: const Color(0xFF5A5A7A),
        ),
        bodyMedium: GoogleFonts.notoSansKR(
          fontSize: 14,
          color: const Color(0xFF6A6A8A),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFE6E6FA).withOpacity(0.8),
        foregroundColor: const Color(0xFF4A4A6A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansKR(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A4A6A),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE6E6FA),
          foregroundColor: const Color(0xFF4A4A6A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE6E6FA), width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE6E6FA),
        brightness: Brightness.dark,
        primary: const Color(0xFF9A8FB0),
        secondary: const Color(0xFFD98C9F),
        tertiary: const Color(0xFF8C9FD9),
        surface: const Color(0xFF1A1A2E),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSansKR(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE6E6FA),
        ),
        displayMedium: GoogleFonts.notoSansKR(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFD0D0F0),
        ),
        bodyLarge: GoogleFonts.notoSansKR(
          fontSize: 16,
          color: const Color(0xFFD0D0F0),
        ),
        bodyMedium: GoogleFonts.notoSansKR(
          fontSize: 14,
          color: const Color(0xFFC0C0E0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1A2E).withOpacity(0.95),
        foregroundColor: const Color(0xFFE6E6FA),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansKR(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE6E6FA),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF252540),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
