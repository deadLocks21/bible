import 'package:bible/core/utils/backend_url.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_base_url.provider.g.dart';

/// Serveur de production, utilisé quand rien n'est passé au build.
const String kProductionApiBaseUrl = 'https://bible.dtfh.fr';

/// URL du serveur visée par l'application, lue de façon synchrone par
/// [dioProvider].
///
/// Elle est fixée à la compilation, et à elle seule :
/// `flutter run --dart-define=API_BASE_URL=http://localhost:8000`. Sans rien,
/// l'application parle à la production.
///
/// Elle est normalisée en origine : un `--dart-define` qui traînerait une barre
/// oblique finale ou un chemin ne produit pas d'URL d'appel bancale.
@Riverpod(keepAlive: true)
String apiBaseUrl(Ref ref) => BackendUrl.normalize(
  const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kProductionApiBaseUrl,
  ),
);
