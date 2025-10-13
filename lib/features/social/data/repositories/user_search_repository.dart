import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/result.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';

/// Repository for user search operations.
class UserSearchRepository {
  UserSearchRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Search users by username.
  Future<Result<List<User>>> searchByUsername(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Success([]);
      }

      // Firestore doesn't support case-insensitive search
      // We'll fetch users and filter client-side for better UX
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('username', isLessThan: '${query.toLowerCase()}z')
          .limit(20)
          .get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromDocument(doc).toEntity())
          .toList();

      return Success(users);
    } catch (e) {
      return Failure('Kullanıcı araması başarısız: ${e.toString()}');
    }
  }

  /// Get user by username (exact match).
  Future<Result<User?>> getUserByUsername(String username) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Success(null);
      }

      final user = UserModel.fromDocument(snapshot.docs.first).toEntity();
      return Success(user);
    } catch (e) {
      return Failure('Kullanıcı bulunamadı: ${e.toString()}');
    }
  }

  /// Get user by ID.
  Future<Result<User?>> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return const Success(null);
      }

      final user = UserModel.fromDocument(doc).toEntity();
      return Success(user);
    } catch (e) {
      return Failure('Kullanıcı bulunamadı: ${e.toString()}');
    }
  }
}

// Provider
final userSearchRepositoryProvider = Provider<UserSearchRepository>((ref) {
  return UserSearchRepository(FirebaseFirestore.instance);
});
