import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../shared/models/result.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// ============================================================================
// Firebase Instances
// ============================================================================

/// Provider for Firebase Auth instance.
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

/// Provider for Firestore instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for Google Sign In instance.
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    // Web client ID for Google Sign In
    clientId: '167069643931-okbnjkorvbqfpgkjrp2uqth58klneian.apps.googleusercontent.com',
  );
});

// ============================================================================
// Data Layer Providers
// ============================================================================

/// Provider for auth remote data source.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(googleSignInProvider),
  );
});

/// Provider for auth repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
  );
});

// ============================================================================
// Auth State Providers
// ============================================================================

/// Stream provider for authentication state changes.
/// Emits [User] when signed in, null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Future provider for getting current user.
/// Returns [User] if signed in, null otherwise.
final currentUserProvider = FutureProvider<User?>((ref) async {
  final result = await ref.watch(authRepositoryProvider).getCurrentUser();
  if (result is Success<User?>) {
    return result.data;
  }
  return null;
});

// ============================================================================
// Loading State Provider
// ============================================================================

/// Provider for managing authentication loading state.
/// Useful for showing loading indicators during auth operations.
final authLoadingProvider = StateProvider<bool>((ref) => false);