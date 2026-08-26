enum UserRole {
  admin,
  user,
}

class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.role,
  });
}
