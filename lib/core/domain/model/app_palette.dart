/// Jeu de couleurs choisi par l'utilisateur.
///
/// Indépendant de [AppThemeMode] : la palette dit *quelles* couleurs, le mode
/// dit *clair ou sombre*. Chaque palette existe donc dans les deux ambiances.
enum AppPalette {
  /// Ivoire chaud, encre profonde, accent terre cuite.
  paper,

  /// Ardoise profonde, accent bleu lumineux.
  night,

  /// Presque noir et blanc ; le vert ne sert qu'à l'action.
  mono;

  /// Reconstruit une valeur depuis sa forme persistée, en retombant sur
  /// [AppPalette.paper] pour toute valeur inconnue (préférence écrite par une
  /// version antérieure, stockage corrompu…).
  static AppPalette fromName(String? name) {
    return AppPalette.values.firstWhere(
      (palette) => palette.name == name,
      orElse: () => AppPalette.paper,
    );
  }
}
