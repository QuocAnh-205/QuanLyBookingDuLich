import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF009688); // Teal
  static const Color secondaryColor = Color(0xFFFFD600); // Yellow
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Roboto', // Default modern sans-serif
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
          shadowColor: Colors.black26,
        ),
      ),
    );
  }
}
