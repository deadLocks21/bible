import 'package:bible/core/domain/model/user.dart';

/// Projection d'un [User] pour l'UI.
class UserDto {
  final int id;
  final String name;
  final String email;

  const UserDto({required this.id, required this.name, required this.email});

  factory UserDto.fromDomain(User user) =>
      UserDto(id: user.id, name: user.name, email: user.email);
}
