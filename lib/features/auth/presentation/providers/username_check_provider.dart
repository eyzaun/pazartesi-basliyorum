import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to check if a username is available.
final usernameCheckProvider =
    FutureProvider.family<bool, String>((ref, username) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final query = await firestore
        .collection('users')
        .where('username', isEqualTo: username.trim())
        .limit(1)
        .get();

    // If no documents found, username is available
    return query.docs.isEmpty;
  } catch (e) {
    // On error, assume username is not available to be safe
    return false;
  }
});
