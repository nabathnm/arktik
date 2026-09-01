import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRemoteDataSource {
  Future<User?> getCurrentUser();
  Future<Map<String, dynamic>?> getUserProfile(String userId);
  Future<Map<String, dynamic>> createUserProfile({
    required String userId,
    required String email,
    String? name,
    String? avatarUrl,
  });
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Stream<AuthState> authStateChanges();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl(this.supabaseClient, this.googleSignIn);

  @override
  Future<User?> getCurrentUser() async {
    return supabaseClient.auth.currentUser;
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> createUserProfile({
    required String userId,
    required String email,
    String? name,
    String? avatarUrl,
  }) async {
    final newProfile = {
      'id': userId,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'role': 'user', // Default role
    };

    final response = await supabaseClient
        .from('profiles')
        .insert(newProfile)
        .select()
        .single();

    return response;
  }

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:3000',
        scopes:
            'email profile https://www.googleapis.com/auth/calendar.events https://www.googleapis.com/auth/calendar.readonly',
        queryParams: {
          'prompt': 'consent',
          'access_type': 'offline',
        },
      );
      return;
    }

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('User cancelled Google Sign In');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw Exception('No Access Token found.');
    }
    if (idToken == null) {
      throw Exception('No ID Token found.');
    }

    await supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await supabaseClient.auth.signOut();
  }

  @override
  Stream<AuthState> authStateChanges() {
    return supabaseClient.auth.onAuthStateChange;
  }
}
