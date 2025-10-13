/// Base exception class for the application.
/// Exceptions are thrown by data sources and caught by repositories.
class AppException implements Exception {
  const AppException(
    this.message, {
    this.code,
    this.originalException,
  });
  final String message;
  final String? code;
  final dynamic originalException;

  @override
  String toString() =>
      'AppException: $message${code != null ? " (Code: $code)" : ""}';
}

// ============================================================================
// Network Exceptions
// ============================================================================

/// Exception thrown when there's no internet connection.
class NetworkException extends AppException {
  const NetworkException([String? message])
      : super(message ?? 'No internet connection', code: 'NETWORK_ERROR');
}

/// Exception thrown when request times out.
class TimeoutException extends AppException {
  const TimeoutException([String? message])
      : super(message ?? 'Request timeout', code: 'TIMEOUT');
}

/// Exception thrown when server returns an error.
class ServerException extends AppException {
  const ServerException([String? message])
      : super(message ?? 'Server error', code: 'SERVER_ERROR');
}

// ============================================================================
// Cache Exceptions
// ============================================================================

/// Exception thrown when cache operation fails.
class CacheException extends AppException {
  const CacheException([String? message])
      : super(message ?? 'Cache error', code: 'CACHE_ERROR');
}

/// Exception thrown when cached data is not found.
class CacheNotFoundException extends CacheException {
  const CacheNotFoundException([String? message])
      : super(message ?? 'Cache not found');
}

// ============================================================================
// Database Exceptions
// ============================================================================

/// Exception thrown during database operations.
class DatabaseException extends AppException {
  const DatabaseException([String? message])
      : super(message ?? 'Database error', code: 'DATABASE_ERROR');
}

/// Exception thrown when database query fails.
class QueryException extends DatabaseException {
  const QueryException([String? message]) : super(message ?? 'Query failed');
}

/// Exception thrown when database insert fails.
class InsertException extends DatabaseException {
  const InsertException([String? message]) : super(message ?? 'Insert failed');
}

/// Exception thrown when database update fails.
class UpdateException extends DatabaseException {
  const UpdateException([String? message]) : super(message ?? 'Update failed');
}

/// Exception thrown when database delete fails.
class DeleteException extends DatabaseException {
  const DeleteException([String? message]) : super(message ?? 'Delete failed');
}

// ============================================================================
// Authentication Exceptions
// ============================================================================

/// Exception thrown during authentication operations.
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Exception thrown when user is not authenticated.
class UnauthenticatedException extends AuthException {
  const UnauthenticatedException()
      : super('User not authenticated', code: 'UNAUTHENTICATED');
}

/// Exception thrown when credentials are invalid.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Invalid credentials', code: 'INVALID_CREDENTIALS');
}

/// Exception thrown when user already exists.
class UserAlreadyExistsException extends AuthException {
  const UserAlreadyExistsException()
      : super('User already exists', code: 'USER_EXISTS');
}

/// Exception thrown when user is not found.
class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('User not found', code: 'USER_NOT_FOUND');
}

// ============================================================================
// Validation Exceptions
// ============================================================================

/// Exception thrown when validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Exception thrown when required field is missing.
class MissingFieldException extends ValidationException {
  const MissingFieldException(String fieldName)
      : super('Missing required field: $fieldName', code: 'MISSING_FIELD');
}

/// Exception thrown when field format is invalid.
class InvalidFormatException extends ValidationException {
  const InvalidFormatException(String fieldName)
      : super('Invalid format for field: $fieldName', code: 'INVALID_FORMAT');
}

// ============================================================================
// Permission Exceptions
// ============================================================================

/// Exception thrown when user lacks permission.
class PermissionException extends AppException {
  const PermissionException([String? message])
      : super(message ?? 'Permission denied', code: 'PERMISSION_DENIED');
}

/// Exception thrown when resource is not found.
class NotFoundException extends AppException {
  const NotFoundException([String? message])
      : super(message ?? 'Resource not found', code: 'NOT_FOUND');
}

// ============================================================================
// File Exceptions
// ============================================================================

/// Exception thrown during file operations.
class FileException extends AppException {
  const FileException(super.message, {super.code});
}

/// Exception thrown when file is not found.
class FileNotFoundException extends FileException {
  const FileNotFoundException([String? filePath])
      : super(
          'File not found${filePath != null ? ": $filePath" : ""}',
          code: 'FILE_NOT_FOUND',
        );
}

/// Exception thrown when file read fails.
class FileReadException extends FileException {
  const FileReadException([String? message])
      : super(message ?? 'Failed to read file', code: 'FILE_READ_ERROR');
}

/// Exception thrown when file write fails.
class FileWriteException extends FileException {
  const FileWriteException([String? message])
      : super(message ?? 'Failed to write file', code: 'FILE_WRITE_ERROR');
}

// ============================================================================
// Sync Exceptions
// ============================================================================

/// Exception thrown during synchronization.
class SyncException extends AppException {
  const SyncException([String? message])
      : super(message ?? 'Synchronization failed', code: 'SYNC_ERROR');
}

/// Exception thrown when sync conflict occurs.
class SyncConflictException extends SyncException {
  const SyncConflictException() : super('Sync conflict detected');
}

// ============================================================================
// Helper Functions
// ============================================================================

/// Convert exception to user-friendly message.
String getExceptionMessage(Exception exception, {String? defaultMessage}) {
  if (exception is AppException) {
    return exception.message;
  } else if (exception is NetworkException) {
    return 'İnternet bağlantınızı kontrol edin';
  } else if (exception is TimeoutException) {
    return 'İstek zaman aşımına uğradı';
  } else if (exception is ServerException) {
    return 'Sunucu hatası oluştu';
  } else if (exception is DatabaseException) {
    return 'Veritabanı hatası';
  } else if (exception is AuthException) {
    return 'Kimlik doğrulama hatası';
  }

  return defaultMessage ?? 'Beklenmeyen bir hata oluştu';
}
