import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:flutter/material.dart';

/// Thèmes de l'application.
///
/// La teinte reprend celle de l'application web : une base neutre très
/// désaturée (les jetons `--background` / `--foreground` de son thème sombre),
/// pour que le passage du web au mobile ne surprenne pas.
class AppThemeData {
  const AppThemeData._();

  /// Couleur de base des schémas générés.
  static const Color seedColor = Color(0xFF6B7280);

  static ThemeData buildLightTheme() => _build(Brightness.light);

  static ThemeData buildDarkTheme() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      // Les champs de saisie sont encadrés comme sur le web, où chaque champ
      // porte une bordure visible plutôt qu'un simple soulignement.
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }

  /// Convertit la préférence du domaine en [ThemeMode] de Flutter.
  static ThemeMode toFlutterThemeMode(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }
}
