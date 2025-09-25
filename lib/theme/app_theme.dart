import 'package:flutter/material.dart';

class AppTheme {
  // PRIMARY PALETTE
  // Deep Forest Green - represents nature, healing herbs, and balance
  static const Color primaryColor = Color(0xFF2D5016);
  static const Color primaryVariant = Color(0xFF3A5F3A);
  
  // Warm Saffron/Turmeric - connects to traditional spices and spiritual practices
  static const Color saffronColor = Color(0xFFE4A853);
  static const Color turmericColor = Color(0xFFD4AF37);
  
  // Soft Cream/Off-white - for clean backgrounds and breathing space
  static const Color backgroundColor = Color(0xFFF7F5F3);
  static const Color backgroundVariant = Color(0xFFFAF8F5);
  
  // SECONDARY/ACCENT COLORS
  // Terracotta/Clay - earthy, grounding, represents traditional pottery
  static const Color terracottaColor = Color(0xFFB5651D);
  static const Color clayColor = Color(0xFFCD853F);
  
  // Soft Sage Green - gentle, calming, medicinal plants
  static const Color softSageColor = Color(0xFF9CAF88);
  static const Color sageVariant = Color(0xFFA8B5A0);
  
  // Warm Gold - for highlights and premium features
  static const Color warmGoldColor = Color(0xFFB8860B);
  
  // SUPPORTING NEUTRALS
  // Charcoal Brown - for text and serious content
  static const Color textColor = Color(0xFF3E2723);
  
  // Light Sage Gray - for subtle backgrounds and dividers
  static const Color lightSageGray = Color(0xFFE8EDE8);
  
  // Convenience colors for common usage
  static const Color surfaceColor = Color(0xFFFAF8F5);
  static const Color accentColor = Color(0xFFE4A853);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: terracottaColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: backgroundColor,
        onSecondary: backgroundColor,
        tertiary: saffronColor,
        onTertiary: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: terracottaColor,
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softSageColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softSageColor.withOpacity(0.6)),
        ),
        filled: true,
        fillColor: surfaceColor,
        labelStyle: const TextStyle(color: textColor),
        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shadowColor: textColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: saffronColor,
        foregroundColor: textColor,
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textColor.withOpacity(0.6),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(
        color: lightSageGray,
        thickness: 1,
      ),
    );
  }

  // Dark theme for accessibility (optional)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryVariant,
        brightness: Brightness.dark,
        primary: saffronColor,
        secondary: warmGoldColor,
        background: textColor,
        surface: Color(0xFF2D2D2D),
        onPrimary: textColor,
        onSecondary: textColor,
        tertiary: softSageColor,
      ),
      scaffoldBackgroundColor: textColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: saffronColor,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // Utility methods for color variations
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // Gradient combinations for Ayurvedic aesthetics
  static LinearGradient get healingGradient => const LinearGradient(
    colors: [primaryColor, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get warmthGradient => const LinearGradient(
    colors: [saffronColor, turmericColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get earthGradient => const LinearGradient(
    colors: [terracottaColor, clayColor],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient get serenityGradient => const LinearGradient(
    colors: [softSageColor, sageVariant],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}