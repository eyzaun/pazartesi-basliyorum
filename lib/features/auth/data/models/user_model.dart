import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// Data model for User that extends the domain entity.
/// Handles serialization/deserialization for Firebase Firestore.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.displayName,
    super.photoUrl,
  });

  /// Create UserModel from domain entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }

  /// Create UserModel from Firestore document.
  factory UserModel.fromFirestore(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoURL'] as String?,
    );
  }

  /// Create UserModel from Firestore DocumentSnapshot.
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromFirestore(data);
  }

  /// Convert UserModel to Firestore map.
  /// This is used when creating a new user document.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': id,
      'email': email,
      'username': username,
      'usernameLower': username.toLowerCase(), // For case-insensitive search
      'displayName': displayName,
      'photoURL': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'stats': {
        'totalCompletions': 0,
        'currentStreak': 0,
        'longestStreak': 0,
      },
      'privacy': {
        'profileVisibility': 'public',
        'allowFriendRequests': true,
      },
    };
  }

  /// Convert UserModel to domain entity.
  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  /// Create a copy of this UserModel with some fields replaced.
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
