import 'package:flutter_bloc/flutter_bloc.dart';
import '../../errors/exceptions.dart';
import '../../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState.initial());

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(AuthState.unauthenticated());
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (error) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.signIn(
        emailOrUsername: emailOrUsername,
        password: password,
      );
      emit(AuthState.authenticated(user));
    } on ValidationException catch (error) {
      emit(AuthState.error(error.message));
    } on AuthException catch (error) {
      emit(AuthState.error(error.message));
    } on NetworkException catch (error) {
      emit(AuthState.error(error.message));
    } catch (error) {
      emit(const AuthState.error('An unexpected error occurred'));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? username,
  }) async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        username: username,
      );

      emit(AuthState.authenticated(user));
    } on ValidationException catch (error) {
      emit(AuthState.error(error.message));
    } on AuthException catch (error) {
      emit(AuthState.error(error.message));
    } on NetworkException catch (error) {
      emit(AuthState.error(error.message));
    } catch (error) {
      emit(const AuthState.error('An unexpected error occurred'));
    }
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());

    try {
      await _authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (error) {
      emit(const AuthState.error('Failed to sign out'));
    }
  }
}
