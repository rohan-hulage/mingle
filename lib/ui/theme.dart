import 'package:flutter/material.dart';

class MingleTheme {
  static const purple = Color(0xFF5935B5);
  static const violet = Color(0xFF8A61EB);
  static const ink = Color(0xFF211A31);
  static const canvas = Color(0xFFF8F6FC);

  static ThemeData get light => _create(Brightness.light);
  static ThemeData get dark => _create(Brightness.dark);

  static ThemeData _create(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: purple,
      brightness: brightness,
      surface: dark ? const Color(0xFF191620) : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF111016) : canvas,
      textTheme: ThemeData(brightness: brightness, useMaterial3: true).textTheme
          .apply(
            bodyColor: dark ? const Color(0xFFF5F1FC) : ink,
            displayColor: dark ? const Color(0xFFF5F1FC) : ink,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF111016) : canvas,
        foregroundColor: dark ? Colors.white : ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: dark ? Colors.white : ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF201D28) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF25212F) : const Color(0xFFF5F2F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: violet, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF191620) : Colors.white,
        indicatorColor: dark
            ? const Color(0xFF392A58)
            : const Color(0xFFEDE6FB),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}
