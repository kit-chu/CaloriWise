import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryCoral = Color(0xFFFF6B6B);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF6B7280);

  // Text Theme
  static TextTheme get _textTheme => TextTheme(
        // Display styles
        displayLarge: GoogleFonts.prompt(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.prompt(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.16,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.prompt(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.22,
          color: textPrimary,
        ),
        // Headline styles
        headlineLarge: GoogleFonts.prompt(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.25,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.prompt(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.29,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.prompt(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.33,
          color: textPrimary,
        ),
        // Title styles
        titleLarge: GoogleFonts.prompt(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.27,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.prompt(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.prompt(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: textPrimary,
        ),
        // Body styles
        bodyLarge: GoogleFonts.prompt(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.prompt(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.prompt(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
          color: textSecondary,
        ),
        // Label styles
        labelLarge: GoogleFonts.prompt(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.prompt(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
          color: textPrimary,
        ),
        labelSmall: GoogleFonts.prompt(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
          color: textSecondary,
        ),
      );

  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryPurple),
    useMaterial3: true,
    textTheme: _textTheme,
    scaffoldBackgroundColor: backgroundLight,

    appBarTheme: AppBarTheme(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: _textTheme.titleLarge?.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    // ✅ เพิ่ม Dialog theme สำหรับ Google Sign-In
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      elevation: 16,
      shadowColor: Colors.black.withOpacity(0.3),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: _textTheme.titleLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: _textTheme.bodyMedium?.copyWith(
        color: textSecondary,
      ),
    ),

    // ✅ เพิ่ม BottomSheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      modalElevation: 20,
      modalBackgroundColor: Colors.white,
    ),

    // ✅ เพิ่ม Card theme สำหรับ account selection
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.2),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ✅ เพิ่ม List tile theme สำหรับ account list
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      titleTextStyle: _textTheme.bodyLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: _textTheme.bodyMedium?.copyWith(
        color: textSecondary,
      ),
    ),

    // ✅ เพิ่ม Divider theme
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 16,
    ),
  );



}