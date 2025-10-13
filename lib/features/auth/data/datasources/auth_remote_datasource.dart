import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      
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
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore());
      
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
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw firebase_auth.FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: 'Google girişi başarısız',
        );
      }
      
      // Check if user exists in Firestore
      print('🔍 [Google Sign-In] Checking if user exists: ${userCredential.user!.uid}');
      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      print('🔍 [Google Sign-In] Document exists: ${doc.exists}');
      
      if (!doc.exists) {
        // Create new user document
        // Generate unique username from email
        print('📝 [Google Sign-In] Creating new user document');
        String baseUsername = userCredential.user!.email!.split('@')[0];
        String username = baseUsername;
        
        print('🔍 [Google Sign-In] Checking username availability: $username');
        // Check if username exists and add random suffix if needed
        final usernameQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();
        
        print('🔍 [Google Sign-In] Username query returned: ${usernameQuery.docs.length} results');
        
        if (usernameQuery.docs.isNotEmpty) {
          // Username taken, add random suffix
          username = '${baseUsername}_${DateTime.now().millisecondsSinceEpoch % 10000}';
          print('🔄 [Google Sign-In] Username taken, using: $username');
        }
        
        final user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          username: username,
          displayName: userCredential.user!.displayName ?? username,
          photoUrl: userCredential.user!.photoURL,
        );
        
        print('💾 [Google Sign-In] Saving user to Firestore: ${user.username}');
        try {
          await _firestore
              .collection('users')
              .doc(user.id)
              .set(user.toFirestore());
          print('✅ [Google Sign-In] User document created successfully');
        } catch (e) {
          print('❌ [Google Sign-In] Failed to create user document: $e');
          rethrow;
        }
        
        return user;
      }
      
      print('✅ [Google Sign-In] Existing user found: ${doc.data()?['username']}');
      return UserModel.fromFirestore(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sign out from Firebase and Google.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
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
      
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      
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
        print('🔍 [AuthStateChanges] Checking user: ${firebaseUser.uid}');
        
        // Retry logic for newly created users (race condition fix)
        for (int attempt = 0; attempt < 3; attempt++) {
          final doc = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get();
          
          print('🔍 [AuthStateChanges] Document exists: ${doc.exists} (attempt ${attempt + 1})');
          
          if (doc.exists) {
            print('✅ [AuthStateChanges] User found: ${doc.data()?['username']}');
            return UserModel.fromFirestore(doc.data()!);
          }
          
          // If document doesn't exist and this is not the last attempt, wait and retry
          if (attempt < 2) {
            print('⏳ [AuthStateChanges] Document not found yet, waiting 500ms...');
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
        
        // After 3 attempts, document still doesn't exist
        print('❌ [AuthStateChanges] User document not found for: ${firebaseUser.uid}');
        print('   Email: ${firebaseUser.email}');
        print('   Display Name: ${firebaseUser.displayName}');
        return null;
      } catch (e) {
        print('❌ [AuthStateChanges] Error: $e');
        return null;
      }
    });
  }
}