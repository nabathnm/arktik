import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.avatarUrl,
    required super.role,
  });

  factory UserModel.fromSupabase(User user, Map<String, dynamic>? profile) {
    UserRole role = UserRole.user;

    if (profile != null && profile['role'] != null) {
      final roleStr = profile['role'].toString().toLowerCase();
      if (roleStr == 'admin') {
        role = UserRole.admin;
      }
    }

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: profile != null
          ? profile['name'] as String?
          : user.userMetadata?['full_name'],
      avatarUrl: profile != null
          ? profile['avatar_url'] as String?
          : user.userMetadata?['avatar_url'],
      role: role,
    );
  }
}
