/// Stockage des préférences d'affichage du tableau de bord.
///
/// Le bandeau de régularité est replié par défaut : il ne doit pas repousser la
/// lecture du jour hors de l'écran à chaque ouverture. Le choix de l'utilisateur
/// lui survit d'un lancement à l'autre.
abstract interface class DashboardPreferencesRepository {
  Future<bool> isStatsExpanded();

  Future<void> setStatsExpanded(bool expanded);
}
