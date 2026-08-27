# Bible — application mobile

Application Flutter du plan de lecture biblique, pendant mobile du site servi par `../api`.

Elle affiche le plan actif de l'utilisateur, sa lecture du jour et les suivantes, permet d'écouter les chapitres correspondants dans un lecteur YouTube intégré, de marquer une lecture comme lue, et de gérer son compte.

## Démarrer

```bash
flutter pub get
```

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

Sans `--dart-define`, l'application vise la production (`https://bible.dtfh.fr`). Sur émulateur Android, utiliser `http://10.0.2.2:8000` pour joindre un serveur lancé sur la machine hôte.

## Observabilité

Les logs applicatifs partent vers [Signoz](https://signoz.io) en OTLP/HTTP, sous
`service.name=bible`. La configuration est fixée à la compilation :

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=SIGNOZ_INGEST_URL=https://signoz.example.org:4318/v1/logs \
  --dart-define=SIGNOZ_INGESTION_KEY=... \
  --dart-define=SIGNOZ_ENV=development
```

| `--dart-define`         | Rôle                                                                 |
|-------------------------|----------------------------------------------------------------------|
| `SIGNOZ_INGEST_URL`     | Point d'entrée OTLP. **Vide → aucun export**, la console suffit.     |
| `SIGNOZ_INGESTION_KEY`  | En-tête `signoz-access-token`. Inutile sur une instance sans auth.   |
| `SIGNOZ_ENV`            | `deployment.environment`. À défaut : `production` en release.        |
| `APP_VERSION`           | `service.version`. À défaut : `dev`.                                 |

Sans `SIGNOZ_INGEST_URL`, l'application ne journalise que dans la console — c'est
le cas d'un `flutter run` ordinaire. Avec, en build de développement, les deux
sinks fonctionnent en parallèle : la console affiche, préfixé `[→signoz]`,
exactement ce qui part sur le réseau. En release, seul Signoz reste.

En CI, les trois valeurs viennent des secrets GitHub du même nom (cf.
[.github/workflows/release.yml](.github/workflows/release.yml)).

### Ce qui est journalisé

| Message           | Niveau      | Quand                                                        |
|-------------------|-------------|--------------------------------------------------------------|
| `app.started`     | info        | Au lancement.                                                 |
| `app.lifecycle`   | info        | Mise en arrière-plan / retour. Vide le tampon d'envoi.        |
| `ui.screen`       | info        | Ouverture et fermeture d'un écran.                            |
| `auth.state`      | info        | Connexion, déconnexion, absence de session au démarrage.      |
| `auth.*`          | info / warn | Connexion, inscription, jeton absent ou illisible, révocation.|
| `reading.*`       | info / warn | Lecture marquée lue, chargement du plan, de l'historique…     |
| `profile.*`       | info / warn | Profil, mot de passe, suppression de compte.                  |
| `settings.*`      | warn/error  | Préférence de thème ou d'affichage illisible ou non écrite.   |
| `player.*`        | info / warn | Lecteur YouTube : ouverture, vidéo indisponible, erreur JS.   |
| `http.call`       | debug       | Chaque appel HTTP abouti, avec sa durée.                      |
| `http.failed`     | warn/error  | 4xx en `warn`, 5xx et serveur injoignable en `error`.         |
| `flutter.error`   | error       | Erreur de framework non rattrapée (build, layout, callback).  |
| `dart.uncaught`   | error       | Erreur asynchrone échappée de toutes les zones.               |
| `provider.failed` | error       | Erreur levée dans un provider Riverpod.                       |

Chaque enregistrement porte `session.id` (une valeur par lancement) et, une fois
connecté, `user.id`. Filtrer sur `session.id` reconstitue une exécution complète,
du démarrage à l'erreur.

### Les erreurs non rattrapées

Les trois derniers messages du tableau forment le filet. Ils couvrent, vérifié
sonde en main :

- une exception levée dans un `build`, un callback de frame ou de scheduler
  → `flutter.error` ;
- un `Future` non attendu, un `Timer`, un `Stream` sans `onError`
  → `dart.uncaught` ;
- une exception levée dans un provider Riverpod → `provider.failed`.

Ce dernier cas mérite son propre crochet : Riverpod rattrape ce que lève un
provider pour le ranger dans son état, l'erreur ne traverse donc **jamais** les
deux autres. Un provider qui échoue sans que l'écran n'en dise rien serait
autrement totalement muet. L'enregistrement est émis une seule fois, une fois les
tentatives de Riverpod épuisées — pas une par tentative.

Restent hors de portée les **plantages natifs** (Swift/Obj-C, JVM, la vue web) :
ils tuent l'isolat Dart avant que le moindre crochet ne s'exécute. Il faudrait
Crashlytics ou Sentry pour ceux-là.

**Ne sont jamais journalisés** : mots de passe, jetons, corps de requête et de
réponse, en-têtes HTTP, adresses e-mail. Voir
`lib/infrastructure/http/logging.interceptor.dart`.

## Génération de code

Les providers Riverpod sont générés :

```bash
dart run build_runner build
```

## Tests

```bash
flutter test
```

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — organisation des couches, conventions de nommage, ajout d'une fonctionnalité.
- [../api/API.md](../api/API.md) — contrat de l'API JSON consommée par l'application.
