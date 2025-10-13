import 'package:equatable/equatable.dart';

/// Domain entity representing a user in the application.
/// This is the core business object that's independent of any framework.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.photoUrl,
  });
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? photoUrl;

  /// Create a copy of this User with some fields replaced.
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, username, displayName, photoUrl];

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, '
        'displayName: $displayName, photoUrl: $photoUrl)';
  }
}
