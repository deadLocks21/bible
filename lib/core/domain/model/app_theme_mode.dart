/// Préférence de thème de l'utilisateur.
///
/// Doublon volontaire du `ThemeMode` de Flutter : le domaine ne dépend pas du
/// framework. La conversion vit dans `AppThemeData.toFlutterThemeMode`.
enum AppThemeMode {
  light,
  dark,
  system;

  /// Reconstruit une valeur depuis sa forme persistée, en retombant sur
  /// [AppThemeMode.system] pour toute valeur inconnue (préférence écrite par
  /// une version antérieure, stockage corrompu…).
  static AppThemeMode fromName(String? name) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => AppThemeMode.system,
    );
  }
}
