import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../shared/models/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository].
/// Handles error handling and converts data models to domain entities.
class AuthRepositoryImpl implements AuthRepository {
  
  AuthRepositoryImpl(this.remoteDataSource);
  final AuthRemoteDataSource remoteDataSource;
  
  @override
  Future<Result<User>> signInWithEmail(String email, String password) async {
    try {
      final userModel = await remoteDataSource.signInWithEmail(email, password);
      return Success(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Failure(_handleFirebaseAuthError(e));
    } catch (e) {
      return Failure('Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<User>> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmail(
        email,
        password,
        username,
      );
      return Success(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Failure(_handleFirebaseAuthError(e));
    } catch (e) {
      return Failure('Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return Success(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Failure(_handleFirebaseAuthError(e));
    } catch (e) {
      return Failure('Google girişi başarısız: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Success(null);
    } catch (e) {
      return Failure('Çıkış yapılamadı: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Failure(_handleFirebaseAuthError(e));
    } catch (e) {
      return Failure('Şifre sıfırlama başarısız: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Success(userModel?.toEntity());
    } catch (e) {
      return Failure('Kullanıcı bilgisi alınamadı: ${e.toString()}');
    }
  }
  
  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map(
      (userModel) => userModel?.toEntity(),
    );
  }
  
  /// Handle Firebase Auth errors and return user-friendly messages.
  String _handleFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin';
      case 'username-already-exists':
        return 'Bu kullanıcı adı zaten kullanılıyor';
      case 'user-data-not-found':
        return 'Kullanıcı verisi bulunamadı';
      case 'google-sign-in-cancelled':
        return 'Google girişi iptal edildi';
      case 'google-sign-in-failed':
        return 'Google girişi başarısız oldu';
      default:
        return e.message ?? 'Bir hata oluştu: ${e.code}';
    }
  }
}