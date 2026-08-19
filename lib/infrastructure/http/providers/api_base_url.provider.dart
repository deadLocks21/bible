import 'package:bible/core/utils/backend_url.dart';
import 'package:bible/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_base_url.provider.g.dart';

/// URL du serveur visée par l'application, lue de façon synchrone par
/// [dioProvider].
///
/// Ordre de résolution, du plus prioritaire au moins prioritaire :
///
/// 1. l'URL enregistrée depuis l'écran Réglages, quand l'utilisateur a voulu
///    viser un autre serveur que celui compilé (recette, instance locale) ;
/// 2. la constante de compilation `API_BASE_URL`, passée au build :
///    `flutter run --dart-define=API_BASE_URL=http://localhost:8000` ;
/// 3. [kProductionApiBaseUrl], pour qu'un build sans aucune configuration
///    parle tout de même au serveur de production.
///
/// [load] est appelé une fois au démarrage, avant le premier écran. Changer
/// l'URL via [update] émet un nouvel état, ce qui reconstruit [dioProvider] et
/// les repositories qui l'observent : l'appel suivant part sur le nouveau
/// serveur.
@Riverpod(keepAlive: true)
class ApiBaseUrl extends _$ApiBaseUrl {
  /// Serveur de production, utilisé quand rien d'autre n'est configuré.
  static const String kProductionApiBaseUrl = 'https://bible.dtfh.fr';

  static const String _envFallback = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kProductionApiBaseUrl,
  );

  @override
  String build() => BackendUrl.normalize(_envFallback);

  /// Charge l'URL enregistrée, si elle existe. Appelé une fois au démarrage.
  Future<void> load() async {
    final stored = await ref.read(settingsServiceProvider).getBackendUrl();
    if (stored != null && stored.trim().isNotEmpty) {
      state = BackendUrl.normalize(stored);
    }
  }

  /// Enregistre [url] et bascule l'application dessus.
  Future<void> update(String url) async {
    final normalized = BackendUrl.normalize(url);
    await ref.read(settingsServiceProvider).setBackendUrl(normalized);
    state = normalized;
  }

  /// Oublie l'URL enregistrée et revient à celle du build.
  Future<void> reset() async {
    await ref.read(settingsServiceProvider).clearBackendUrl();
    state = BackendUrl.normalize(_envFallback);
  }

  /// Vrai quand l'application vise le serveur du build, sans redirection.
  bool get isDefault => state == BackendUrl.normalize(_envFallback);
}
