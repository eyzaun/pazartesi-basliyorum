import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Failures represent errors that occurred during business logic execution.
abstract class Failure extends Equatable {
  
  const Failure(this.message);
  final String message;
  
  @override
  List<Object?> get props => [message];
  
  @override
  String toString() => message;
}

// ============================================================================
// General Failures
// ============================================================================

/// Failure that occurs when there's no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([String? message]) 
      : super(message ?? 'İnternet bağlantısı yok');
}

/// Failure that occurs when the server returns an error.
class ServerFailure extends Failure {
  const ServerFailure([String? message]) 
      : super(message ?? 'Sunucu hatası oluştu');
}

/// Failure that occurs when cached data is not available.
class CacheFailure extends Failure {
  const CacheFailure([String? message]) 
      : super(message ?? 'Önbellek hatası');
}

/// Failure that occurs during database operations.
class DatabaseFailure extends Failure {
  const DatabaseFailure([String? message]) 
      : super(message ?? 'Veritabanı hatası');
}

// ============================================================================
// Authentication Failures
// ============================================================================

/// Failure for authentication errors.
class AuthFailure extends Failure {
  const AuthFailure([String? message]) 
      : super(message ?? 'Kimlik doğrulama hatası');
}

/// Failure when user credentials are invalid.
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('E-posta veya şifre hatalı');
}

/// Failure when user is not found.
class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('Kullanıcı bulunamadı');
}

/// Failure when email is already in use.
class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Bu e-posta zaten kullanılıyor');
}

/// Failure when password is too weak.
class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('Şifre çok zayıf');
}

/// Failure when user is not authenticated.
class NotAuthenticatedFailure extends AuthFailure {
  const NotAuthenticatedFailure() : super('Oturum açmanız gerekiyor');
}

// ============================================================================
// Validation Failures
// ============================================================================

/// Failure when input validation fails.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure when required field is empty.
class EmptyFieldFailure extends ValidationFailure {
  const EmptyFieldFailure(String fieldName) 
      : super('$fieldName alanı boş olamaz');
}

/// Failure when email format is invalid.
class InvalidEmailFailure extends ValidationFailure {
  const InvalidEmailFailure() : super('Geçersiz e-posta adresi');
}

/// Failure when password is too short.
class ShortPasswordFailure extends ValidationFailure {
  const ShortPasswordFailure([int minLength = 6]) 
      : super('Şifre en az $minLength karakter olmalı');
}

// ============================================================================
// Permission Failures
// ============================================================================

/// Failure when user doesn't have permission.
class PermissionFailure extends Failure {
  const PermissionFailure([String? message]) 
      : super(message ?? 'Bu işlem için yetkiniz yok');
}

/// Failure when resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([String? message]) 
      : super(message ?? 'Kayıt bulunamadı');
}

// ============================================================================
// Sync Failures
// ============================================================================

/// Failure during data synchronization.
class SyncFailure extends Failure {
  const SyncFailure([String? message]) 
      : super(message ?? 'Senkronizasyon başarısız');
}

// ============================================================================
// Unexpected Failures
// ============================================================================

/// Failure for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String? message]) 
      : super(message ?? 'Beklenmeyen bir hata oluştu');
}

// ============================================================================
// Helper Extensions
// ============================================================================

extension FailureExtension on Failure {
  /// Check if failure is related to network.
  bool get isNetworkFailure => this is NetworkFailure;
  
  /// Check if failure is related to authentication.
  bool get isAuthFailure => this is AuthFailure;
  
  /// Check if failure is related to validation.
  bool get isValidationFailure => this is ValidationFailure;
  
  /// Check if failure is related to permissions.
  bool get isPermissionFailure => this is PermissionFailure;
}