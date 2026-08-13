import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fox_colors.dart';

abstract final class FoxTheme {
  static ThemeData dark() {
    const radius = 14.0;
    final colorScheme = ColorScheme.dark(
      surface: FoxColors.card,
      onSurface: FoxColors.text,
      primary: FoxColors.blue,
      onPrimary: Colors.black,
      secondary: FoxColors.blue2,
      outline: FoxColors.line,
      error: FoxColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FoxColors.bg,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: FoxColors.bg,
        foregroundColor: FoxColors.text,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: FoxColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: FoxColors.line),
        ),
      ),
      dividerColor: FoxColors.line,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FoxColors.bg2,
        indicatorColor: FoxColors.blue.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            color: selected ? FoxColors.blue : FoxColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? FoxColors.blue : FoxColors.muted,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FoxColors.blue,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FoxColors.text,
          side: const BorderSide(color: FoxColors.line),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FoxColors.bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: FoxColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: FoxColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: FoxColors.blue),
        ),
        labelStyle: const TextStyle(color: FoxColors.muted),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: FoxColors.card,
        contentTextStyle: TextStyle(color: FoxColors.text),
      ),
    );
  }
}
