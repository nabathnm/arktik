import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user == null) return null;

      var profile = await remoteDataSource.getUserProfile(user.id);

      return UserModel.fromSupabase(user, profile);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await remoteDataSource.signInWithGoogle();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return remoteDataSource.authStateChanges().asyncMap((authState) async {
      final user = authState.session?.user;
      if (user == null) return null;

      try {
        var profile = await remoteDataSource.getUserProfile(user.id);
        
        if (profile == null) {
          print('====== Profile not found, creating new profile ======');
          profile = await remoteDataSource.createUserProfile(
            userId: user.id,
            email: user.email ?? '',
            name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
            avatarUrl: user.userMetadata?['avatar_url'],
          );
        }

        print('====== DEBUG AUTH ======');
        print('Fetched/Created Profile for ${user.id}: $profile');
        print('Role from Profile: ${profile?['role']}');

        return UserModel.fromSupabase(user, profile);
      } catch (e, stackTrace) {
        print('Error in authStateChanges: $e\n$stackTrace');
        return UserModel.fromSupabase(user, null);
      }
    });
  }
}
