import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';

/// [AuthTokenStore] volatile, utilisé sur le web — où l'on ne veut pas de
/// stockage persistant — et par les tests.
class InMemoryAuthTokenStore implements AuthTokenStore {
  AuthSession? _session;

  InMemoryAuthTokenStore([this._session]);

  @override
  Future<AuthSession?> read() async => _session;

  @override
  Future<void> write(AuthSession session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}
