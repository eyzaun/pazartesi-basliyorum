import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Remote data source for authentication operations.
/// Handles all Firebase Auth and Firestore operations.
class AuthRemoteDataSource {
  AuthRemoteDataSource(
    this._firebaseAuth,
    this._firestore,
    this._googleSignIn,
  );
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Sign in with email and password.
  /// Throws [firebase_auth.FirebaseAuthException] on error.
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw firebase_auth.FirebaseAuthException(
          code: 'user-not-found',
          message: 'Kullanıcı bulunamadı',
        );
      }

      // Get user data from Firestore
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        throw firebase_auth.FirebaseAuthException(
          code: 'user-data-not-found',
          message: 'Kullanıcı verisi bulunamadı',
        );
      }

      return UserModel.fromFirestore(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up with email, password and username.
  /// Creates both Firebase Auth user and Firestore document.
  /// Throws [firebase_auth.FirebaseAuthException] on error.
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Check if username already exists
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw firebase_auth.FirebaseAuthException(
          code: 'username-already-exists',
          message: 'Bu kullanıcı adı zaten kullanılıyor',
        );
      }

      // Create Firebase Auth user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw firebase_auth.FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Kullanıcı oluşturulamadı',
        );
      }

      // Create UserModel
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        username: username,
        displayName: username,
      );

      // Save to Firestore
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google account.
  /// Creates Firestore document if first time sign in.
  /// Throws [firebase_auth.FirebaseAuthException] on error.
  Future<UserModel> signInWithGoogle() async {
    try {
      firebase_auth.UserCredential userCredential;

      if (kIsWeb) {
        // Web platform (iOS Safari, Chrome, etc.)
        final provider = firebase_auth.GoogleAuthProvider();
        
        // Try popup first, fallback to redirect for iOS Safari
        try {
          userCredential = await _firebaseAuth.signInWithPopup(provider);
        } catch (e) {
          // Popup blocked (iOS Safari), use redirect instead
          await _firebaseAuth.signInWithRedirect(provider);
          // After redirect, get the result
          userCredential = await _firebaseAuth.getRedirectResult();
          
          if (userCredential.user == null) {
            throw firebase_auth.FirebaseAuthException(
              code: 'google-sign-in-failed',
              message: 'Google girişi başarısız',
            );
          }
        }
      } else {
        // Mobile platform (Android, iOS app)
        // Check if there's a currently signed in Google user
        final currentUser = await _googleSignIn.signInSilently();

        // If there is, sign out to force account selection
        if (currentUser != null) {
          await _googleSignIn.signOut();
        }

        // Trigger Google Sign In flow (will show account picker)
        final googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          throw firebase_auth.FirebaseAuthException(
            code: 'google-sign-in-cancelled',
            message: 'Google girişi iptal edildi',
          );
        }

        // Get Google Auth credentials
        final googleAuth = await googleUser.authentication;
        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      if (userCredential.user == null) {
        throw firebase_auth.FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: 'Google girişi başarısız',
        );
      }

      // Check if user exists in Firestore
      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        // Return user model without saving to Firestore
        // This indicates that username selection is needed
        return UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          username: '', // Empty username indicates username selection needed
          displayName: userCredential.user!.displayName ?? '',
          photoUrl: userCredential.user!.photoURL,
        );
      }

      return UserModel.fromFirestore(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out from Firebase and Google.
  Future<void> signOut() async {
    try {
      if (kIsWeb) {
        // Web platform - only sign out from Firebase
        await _firebaseAuth.signOut();
      } else {
        // Mobile platform - sign out from both
        await Future.wait([
          _firebaseAuth.signOut(),
          _googleSignIn.signOut(),
        ]);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email.
  /// Throws [firebase_auth.FirebaseAuthException] on error.
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Get the currently signed in user from Firestore.
  /// Returns null if no user is signed in.
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of authentication state changes.
  /// Emits [UserModel] when signed in, null when signed out.
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        // Retry logic for newly created users (race condition fix)
        for (var attempt = 0; attempt < 3; attempt++) {
          final doc =
              await _firestore.collection('users').doc(firebaseUser.uid).get();

          if (doc.exists) {
            return UserModel.fromFirestore(doc.data()!);
          }

          // If document doesn't exist and this is not the last attempt, wait and retry
          if (attempt < 2) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }

        // After 3 attempts, document still doesn't exist
        // This happens for Google sign-in users who haven't completed username selection yet
        // Return a temporary user model with empty username to trigger username selection
        if (firebaseUser.providerData.any((p) => p.providerId == 'google.com')) {
          return UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: '', // Empty username triggers username selection
            displayName: firebaseUser.displayName ?? '',
            photoUrl: firebaseUser.photoURL,
          );
        }
        
        // For other auth methods, return null (should not happen in normal flow)
        return null;
      } catch (e) {
        return null;
      }
    });
  }

  /// Complete Google sign-in by saving user data to Firestore with selected username.
  /// Used after username selection screen.
  Future<UserModel> completeGoogleSignIn({
    required String userId,
    required String email,
    required String username,
    String? photoUrl,
  }) async {
    try {
      final user = UserModel(
        id: userId,
        email: email,
        username: username,
        displayName: username, // Use username as display name
        photoUrl: photoUrl,
      );

      await _firestore.collection('users').doc(user.id).set(user.toFirestore());

      return user;
    } catch (e) {
      rethrow;
    }
  }
}
