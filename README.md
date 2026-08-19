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
