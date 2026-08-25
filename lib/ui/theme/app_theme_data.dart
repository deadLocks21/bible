import 'package:bible/core/domain/model/app_palette.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:flutter/material.dart';

/// Thèmes de l'application.
///
/// Deux réglages indépendants s'y croisent : la **palette**, qui dit quelles
/// couleurs, et le **mode**, qui dit clair ou sombre. Chaque palette est donc
/// définie dans les deux ambiances, et le traitement des formes et de la
/// typographie leur est commun — c'est lui qui donne son air à l'application,
/// la couleur ne fait que l'habiller.
class AppThemeData {
  const AppThemeData._();

  /// Palette servie tant que la préférence n'est pas lue.
  static const AppPalette defaultPalette = AppPalette.paper;

  static ThemeData buildLightTheme([AppPalette palette = defaultPalette]) =>
      _build(_schemes[palette]!.light);

  static ThemeData buildDarkTheme([AppPalette palette = defaultPalette]) =>
      _build(_schemes[palette]!.dark);

  /// Les deux ambiances d'une palette.
  static const Map<AppPalette, ({ColorScheme light, ColorScheme dark})>
  _schemes = {
    AppPalette.paper: (light: _paperLight, dark: _paperDark),
    AppPalette.night: (light: _nightLight, dark: _nightDark),
    AppPalette.mono: (light: _monoLight, dark: _monoDark),
  };

  /// Couleurs d'accent d'une palette, pour la donner à voir dans les réglages
  /// sans avoir à construire un thème entier.
  static List<Color> swatchOf(AppPalette palette) {
    final scheme = _schemes[palette]!;
    return [scheme.light.surface, scheme.light.primary, scheme.dark.surface];
  }

  /// Le socle commun : formes, densités, typographie.
  ///
  /// Les rayons sont larges et les traits rares — la séparation se fait par le
  /// vide plutôt que par des bordures — et les titres sont resserrés
  /// (`letterSpacing` négatif) pour éviter l'air relâché des réglages par
  /// défaut.
  static ThemeData _build(ColorScheme colorScheme) {
    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          letterSpacing: -0.5,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          letterSpacing: -0.3,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(letterSpacing: -0.2),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        // Le titre est le nom de l'écran : il le porte, autant lui donner un
        // vrai corps de titre. La taille est posée en clair — les échelons de
        // Material ne séparent `titleLarge` de `headlineSmall` que de deux
        // points, un écart qui ne se voit pas.
        toolbarHeight: 68,
        titleTextStyle: base.textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 27,
          height: 1.1,
          letterSpacing: -0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
      // Champs remplis plutôt qu'encadrés : un aplat léger tient le champ sans
      // ajouter un trait de plus à l'écran.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: _inputBorder(colorScheme.outlineVariant),
        enabledBorder: _inputBorder(colorScheme.outlineVariant),
        focusedBorder: _inputBorder(colorScheme.primary, width: 2),
        errorBorder: _inputBorder(colorScheme.error),
        focusedErrorBorder: _inputBorder(colorScheme.error, width: 2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: colorScheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.outlineVariant,
      ),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.zero),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  /// Convertit la préférence du domaine en [ThemeMode] de Flutter.
  static ThemeMode toFlutterThemeMode(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }

  // ---------------------------------------------------------------------------
  // Palettes
  // ---------------------------------------------------------------------------

  /// Papier & encre — ivoire chaud, encre profonde, accent terre cuite.
  static const ColorScheme _paperLight = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF9A4A1B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF5E3D3),
    onPrimaryContainer: Color(0xFF3A1A06),
    secondary: Color(0xFF6B5D4F),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFF9F2C1F),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFAF7F2),
    onSurface: Color(0xFF1C1917),
    surfaceContainerHighest: Color(0xFFF0E9DF),
    onSurfaceVariant: Color(0xFF6F675E),
    outline: Color(0xFFB6ACA0),
    outlineVariant: Color(0xFFE3DACD),
  );

  static const ColorScheme _paperDark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE0A252),
    onPrimary: Color(0xFF3A1A06),
    primaryContainer: Color(0xFF52300F),
    onPrimaryContainer: Color(0xFFF5E3D3),
    secondary: Color(0xFFCFC1B1),
    onSecondary: Color(0xFF322C25),
    error: Color(0xFFE99286),
    onError: Color(0xFF56110A),
    surface: Color(0xFF12100E),
    onSurface: Color(0xFFF5F1EA),
    surfaceContainerHighest: Color(0xFF221E19),
    onSurfaceVariant: Color(0xFFA79E92),
    outline: Color(0xFF6B6459),
    outlineVariant: Color(0xFF332E27),
  );

  /// Nuit calme — ardoise profonde, accent bleu lumineux.
  static const ColorScheme _nightLight = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2563EB),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDBE7FE),
    onPrimaryContainer: Color(0xFF102A62),
    secondary: Color(0xFF475569),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF8FAFC),
    onSurface: Color(0xFF0F172A),
    surfaceContainerHighest: Color(0xFFEDF1F7),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFE2E8F0),
  );

  static const ColorScheme _nightDark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF60A5FA),
    onPrimary: Color(0xFF0B213F),
    primaryContainer: Color(0xFF1D3A66),
    onPrimaryContainer: Color(0xFFDBE7FE),
    secondary: Color(0xFF94A3B8),
    onSecondary: Color(0xFF16202E),
    error: Color(0xFFF87171),
    onError: Color(0xFF4A0B0B),
    surface: Color(0xFF0F172A),
    onSurface: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFF1B2740),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF243149),
  );

  /// Monochrome — presque noir et blanc ; le vert ne sert qu'à l'action.
  static const ColorScheme _monoLight = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF047857),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD4F0E4),
    onPrimaryContainer: Color(0xFF02241A),
    secondary: Color(0xFF404040),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFB91C1C),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0A0A0A),
    surfaceContainerHighest: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF737373),
    outline: Color(0xFFA3A3A3),
    outlineVariant: Color(0xFFE5E5E5),
  );

  static const ColorScheme _monoDark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF34D399),
    onPrimary: Color(0xFF02241A),
    primaryContainer: Color(0xFF06503A),
    onPrimaryContainer: Color(0xFFD4F0E4),
    secondary: Color(0xFFA3A3A3),
    onSecondary: Color(0xFF171717),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    surface: Color(0xFF0A0A0A),
    onSurface: Color(0xFFFAFAFA),
    surfaceContainerHighest: Color(0xFF171717),
    onSurfaceVariant: Color(0xFF8F8F8F),
    outline: Color(0xFF525252),
    outlineVariant: Color(0xFF262626),
  );
}
