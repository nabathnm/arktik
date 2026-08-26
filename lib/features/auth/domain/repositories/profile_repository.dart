import '../entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity?> getProfile(String userId);

  Future<UserEntity> createProfile({
    required String userId,
    required String email,
    String? name,
    String? avatarUrl,
  });
}
