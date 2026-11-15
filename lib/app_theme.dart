import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static const navy = Color(0xFF29384D);
  static const cream = Color(0xFFFFF1D4);
  static const red = Color(0xFFF25252);
  static const muted = Color(0xFFBCBEC5);

  static final theme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: navy,
    colorScheme: const ColorScheme.dark(
      primary: cream,
      onPrimary: navy,
      surface: navy,
      onSurface: cream,
      error: red,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      foregroundColor: cream,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: cream,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: const TextStyle(color: muted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: cream),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: cream, width: 2),
      ),
      errorMaxLines: 2,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        backgroundColor: cream,
        foregroundColor: navy,
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cream,
      foregroundColor: navy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: cream,
      contentTextStyle: TextStyle(fontFamily: 'Roboto', color: navy),
      actionTextColor: navy,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
