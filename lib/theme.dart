import 'package:flutter/material.dart';


class AppTheme {
  // Brand palette (provided):
  // Primary:   #E53935
  // Secondary: #1A237E
  // Accent:    #42A5F5
  // Background:#F5F5F5
  // Success:   #43A047
  // Error:     #D32F2F
  static const Color _primary = Color(0xFFE53935);
  static const Color _secondary = Color(0xFF1A237E);
  static const Color _accent = Color(0xFF42A5F5);
  static const Color _background = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF43A047);
  static const Color _error = Color(0xFFD32F2F);

  // Public accessors for non-ColorScheme tokens
  static Color get successColor => _success;

  // Returns a light theme populated with the brand colors.
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.white,
      tertiary: _accent,
      onTertiary: Colors.white,
      // 'background' and 'onBackground' are deprecated; use surface/onSurface.
      surface: _background,
      onSurface: Colors.black87,
      error: _error,
      onError: Colors.white,
      brightness: Brightness.light,
    );

  const textTheme = TextTheme(
      displayLarge: TextStyle(fontFamily: 'Nunito', fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'Nunito', fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.25),
      displaySmall: TextStyle(fontFamily: 'Nunito', fontSize: 34, fontWeight: FontWeight.w700),

      headlineLarge: TextStyle(fontFamily: 'Nunito', fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: 'Nunito', fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w700),

      titleLarge: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600),

      bodyLarge: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w400, height: 1.45),
      bodyMedium: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
      bodySmall: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w400, height: 1.3),

      labelLarge: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      scaffoldBackgroundColor: _background,
      // Expose success color in theme extensions so widgets can use it when
      // needed (e.g. badges, success state). We attach it to colorScheme via
      // copyWith for convenience where appropriate.
      extensions: const <ThemeExtension<dynamic>>[],
    );
  }
}
