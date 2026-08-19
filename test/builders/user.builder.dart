import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/model/user.dart';

User aUser({int id = 1, String name = 'Jean Dupont', String email = 'jean@example.com'}) =>
    User(id: id, name: name, email: email);

AuthSession anAuthSession({String token = 'token-1', User? user}) =>
    AuthSession(token: token, user: user ?? aUser());
