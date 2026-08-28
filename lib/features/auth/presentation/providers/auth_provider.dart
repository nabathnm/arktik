import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/observe_auth_state.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

enum AuthStateStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final GetCurrentUser _getCurrentUser;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final ObserveAuthState _observeAuthState;

  AuthStateStatus _status = AuthStateStatus.initial;
  UserEntity? _user;
  String? _errorMessage;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthProvider({
    required this._getCurrentUser,
    required this._signInWithGoogle,
    required this._signOut,
    required this._observeAuthState,
  }) {
    _init();
  }

  AuthStateStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;

  void _init() {
    _authSubscription = _observeAuthState().listen((user) {
      if (user != null) {
        _user = user;
        _status = AuthStateStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStateStatus.unauthenticated;
      }
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _status = AuthStateStatus.error;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _signInWithGoogle();
      // Auth state stream will handle the status update to authenticated
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStateStatus.error;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _status = AuthStateStatus.loading;
    notifyListeners();

    try {
      await _signOut();
      // Auth state stream will handle the status update to unauthenticated
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStateStatus.error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
