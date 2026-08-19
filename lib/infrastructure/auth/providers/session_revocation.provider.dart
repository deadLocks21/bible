import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_revocation.provider.g.dart';

/// Signal émis lorsqu'une route protégée renvoie `401 invalid_token` — jeton
/// révoqué depuis un autre appareil, mot de passe changé ailleurs, compte
/// supprimé (cf. `api/API.md`).
///
/// Un simple compteur : chaque incrément vaut un événement de révocation que
/// l'UI observe pour repasser à l'écran de connexion. Il sert de pont **sans
/// cycle** entre l'intercepteur Dio (infrastructure) et le notifier d'auth
/// (UI), qui ne peuvent pas se référencer directement.
@Riverpod(keepAlive: true)
class SessionRevocation extends _$SessionRevocation {
  @override
  int build() => 0;

  /// Signale une révocation de session.
  void signal() => state = state + 1;
}
