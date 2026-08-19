/// Utilisateur authentifié.
class User {
  final int id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  User copyWith({String? name, String? email}) =>
      User(id: id, name: name ?? this.name, email: email ?? this.email);
}
