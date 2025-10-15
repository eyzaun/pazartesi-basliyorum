import '../../../../shared/models/result.dart';
import '../entities/user.dart';

/// Abstract repository defining authentication operations.
/// This is a contract that the data layer must implement.
/// It follows the Dependency Inversion Principle (SOLID).
abstract class AuthRepository {
  /// Sign in with email and password.
  /// Returns [Success] with [User] if successful, [Failure] otherwise.
  Future<Result<User>> signInWithEmail(String email, String password);

  /// Sign up with email, password and username.
  /// Returns [Success] with [User] if successful, [Failure] otherwise.
  Future<Result<User>> signUpWithEmail(
    String email,
    String password,
    String username,
  );

  /// Sign in with Google account.
  /// Returns [Success] with [User] if successful, [Failure] otherwise.
  Future<Result<User>> signInWithGoogle();

  /// Sign out the current user.
  /// Returns [Success] if successful, [Failure] otherwise.
  Future<Result<void>> signOut();

  /// Send password reset email.
  /// Returns [Success] if email sent, [Failure] otherwise.
  Future<Result<void>> resetPassword(String email);

  /// Get the currently signed in user.
  /// Returns [Success] with [User] if logged in, null if not.
  Future<Result<User?>> getCurrentUser();

  /// Stream of authentication state changes.
  /// Emits [User] when signed in, null when signed out.
  Stream<User?> get authStateChanges;

  /// Complete Google sign-in by creating user document with username.
  /// Returns [Success] with [User] if successful, [Failure] otherwise.
  Future<Result<User>> completeGoogleSignIn({
    required String userId,
    required String email,
    required String username,
    String? photoUrl,
  });
}
