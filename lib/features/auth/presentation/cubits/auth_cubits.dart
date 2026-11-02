// auth cubit: state management

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/auth/domain/entities/app_user.dart';
import 'package:social_bloc/features/auth/domain/repo/auth_repo.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_states.dart';

class AuthCubits extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubits({required this.authRepo}) : super(AuthInitial());

  //check if user is already authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
    }
  }

  //get current user
  AppUser? get currentUser => _currentUser;

  //login with email and password
  Future<void> login(String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(Unauthenticated());
    }
  }

  //register with email and password
  Future<void> register(String name, String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(Unauthenticated());
    }
  }

  //logout
  Future<void> logout() async {
    try {
      emit(AuthLoading());
      await authRepo.logout();
      _currentUser = null;
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
