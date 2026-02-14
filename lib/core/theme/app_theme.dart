import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // FASHIN Play Color Palette
  
  // Light Mode Colors
  static const Color lightPrimaryColor = Color(0xFF81D4FA); // Light Blue
  static const Color lightAccentColor = Color(0xFF0277BD); // Dark Blue
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightCardColor = Color(0xFFF5F5F5);
  static const Color lightBatikColor = Color(0xFF0288D1);
  static const Color lightGoldColor = Color(0xFFFFD700);
  
  // Dark Mode Colors
  static const Color darkPrimaryColor = Color(0xFF4FC3F7); // Lighter Blue for dark
  static const Color darkAccentColor = Color(0xFF81D4FA); // Light Blue for accents
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkBatikColor = Color(0xFF1565C0);
  static const Color darkGoldColor = Color(0xFFD4AF37);

  // Text styles for readability
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0BEC5);

  static ThemeData lightTheme() {
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme);
    
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: lightPrimaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      dividerColor: Colors.grey[300],
      useMaterial3: true,
      
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: lightTextPrimary),
        displayMedium: textTheme.displayMedium?.copyWith(color: lightTextPrimary),
        displaySmall: textTheme.displaySmall?.copyWith(color: lightTextPrimary),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: lightTextPrimary),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: lightTextPrimary),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: lightTextPrimary),
        titleLarge: textTheme.titleLarge?.copyWith(color: lightTextPrimary),
        titleMedium: textTheme.titleMedium?.copyWith(color: lightTextPrimary),
        titleSmall: textTheme.titleSmall?.copyWith(color: lightTextPrimary),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: lightTextPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: lightTextPrimary),
        bodySmall: textTheme.bodySmall?.copyWith(color: lightTextSecondary),
        labelLarge: textTheme.labelLarge?.copyWith(color: lightTextPrimary),
        labelMedium: textTheme.labelMedium?.copyWith(color: lightTextPrimary),
        labelSmall: textTheme.labelSmall?.copyWith(color: lightTextSecondary),
      ),
      
      colorScheme: ColorScheme.light(
        primary: lightPrimaryColor,
        secondary: lightAccentColor,
        surface: lightCardColor,
        background: lightBackgroundColor,
        error: Colors.red[700]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
        onError: Colors.white,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightBackgroundColor,
        selectedItemColor: lightAccentColor,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      cardTheme: CardThemeData(
        color: lightCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: lightTextPrimary,
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightAccentColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      dividerColor: Colors.white12,
      useMaterial3: true,
      
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: darkTextPrimary),
        displayMedium: textTheme.displayMedium?.copyWith(color: darkTextPrimary),
        displaySmall: textTheme.displaySmall?.copyWith(color: darkTextPrimary),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: darkTextPrimary),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: darkTextPrimary),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: darkTextPrimary),
        titleLarge: textTheme.titleLarge?.copyWith(color: darkTextPrimary),
        titleMedium: textTheme.titleMedium?.copyWith(color: darkTextPrimary),
        titleSmall: textTheme.titleSmall?.copyWith(color: darkTextPrimary),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: darkTextPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: darkTextPrimary),
        bodySmall: textTheme.bodySmall?.copyWith(color: darkTextSecondary),
        labelLarge: textTheme.labelLarge?.copyWith(color: darkTextPrimary),
        labelMedium: textTheme.labelMedium?.copyWith(color: darkTextPrimary),
        labelSmall: textTheme.labelSmall?.copyWith(color: darkTextSecondary),
      ),
      
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: darkAccentColor,
        surface: darkCardColor,
        background: darkBackgroundColor,
        error: Colors.red[300]!,
        onPrimary: darkBackgroundColor,
        onSecondary: darkBackgroundColor,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: darkBackgroundColor,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: darkCardColor,
        foregroundColor: darkTextPrimary,
        elevation: 2,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCardColor,
        selectedItemColor: darkAccentColor,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: darkTextPrimary,
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkAccentColor,
        foregroundColor: darkBackgroundColor,
      ),
    );
  }
}
