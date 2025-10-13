import '../../../../shared/models/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password.
/// Each use case represents a single business action.
class SignInWithEmail {
  SignInWithEmail(this.repository);
  final AuthRepository repository;

  Future<Result<User>> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}

/// Use case for signing up with email and password.
class SignUpWithEmail {
  SignUpWithEmail(this.repository);
  final AuthRepository repository;

  Future<Result<User>> call(String email, String password, String username) {
    return repository.signUpWithEmail(email, password, username);
  }
}

/// Use case for signing in with Google.
class SignInWithGoogle {
  SignInWithGoogle(this.repository);
  final AuthRepository repository;

  Future<Result<User>> call() {
    return repository.signInWithGoogle();
  }
}

/// Use case for signing out.
class SignOut {
  SignOut(this.repository);
  final AuthRepository repository;

  Future<Result<void>> call() {
    return repository.signOut();
  }
}

/// Use case for getting the current user.
class GetCurrentUser {
  GetCurrentUser(this.repository);
  final AuthRepository repository;

  Future<Result<User?>> call() {
    return repository.getCurrentUser();
  }
}
