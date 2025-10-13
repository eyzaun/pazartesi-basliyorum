import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../models/user_model.dart';

/// Local data source for authentication.
/// Handles caching user data and auth tokens.
class AuthLocalDataSource {
  
  AuthLocalDataSource(this.sharedPreferences, this.database);
  final SharedPreferences sharedPreferences;
  final AppDatabase database;
  
  // Keys for SharedPreferences
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'user_email';
  static const String _keyUsername = 'user_username';
  static const String _keyDisplayName = 'user_display_name';
  static const String _keyPhotoUrl = 'user_photo_url';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLastLoginTime = 'last_login_time';
  
  /// Save user data to local storage.
  Future<void> cacheUser(UserModel user) async {
    await Future.wait([
      sharedPreferences.setString(_keyUserId, user.id),
      sharedPreferences.setString(_keyEmail, user.email),
      sharedPreferences.setString(_keyUsername, user.username),
      sharedPreferences.setString(_keyDisplayName, user.displayName),
      sharedPreferences.setString(_keyPhotoUrl, user.photoUrl ?? ''),
      sharedPreferences.setBool(_keyIsLoggedIn, true),
      sharedPreferences.setInt(_keyLastLoginTime, DateTime.now().millisecondsSinceEpoch),
    ]);
    
    // Also cache in database
    await database.cacheUser(
      UsersCompanion(
        id: drift.Value(user.id),
        email: drift.Value(user.email),
        username: drift.Value(user.username),
        displayName: drift.Value(user.displayName),
        photoUrl: drift.Value(user.photoUrl),
        cachedAt: drift.Value(DateTime.now()),
      ),
    );
  }
  
  /// Get cached user data from local storage.
  Future<UserModel?> getCachedUser() async {
    final userId = sharedPreferences.getString(_keyUserId);
    
    if (userId == null) return null;
    
    final email = sharedPreferences.getString(_keyEmail);
    final username = sharedPreferences.getString(_keyUsername);
    final displayName = sharedPreferences.getString(_keyDisplayName);
    final photoUrl = sharedPreferences.getString(_keyPhotoUrl);
    
    if (email == null || username == null || displayName == null) {
      return null;
    }
    
    return UserModel(
      id: userId,
      email: email,
      username: username,
      displayName: displayName,
      photoUrl: photoUrl?.isEmpty == true ? null : photoUrl,
    );
  }
  
  /// Check if user is logged in.
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool(_keyIsLoggedIn) ?? false;
  }
  
  /// Get last login time.
  Future<DateTime?> getLastLoginTime() async {
    final timestamp = sharedPreferences.getInt(_keyLastLoginTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Clear all cached user data (logout).
  Future<void> clearCache() async {
    await Future.wait([
      sharedPreferences.remove(_keyUserId),
      sharedPreferences.remove(_keyEmail),
      sharedPreferences.remove(_keyUsername),
      sharedPreferences.remove(_keyDisplayName),
      sharedPreferences.remove(_keyPhotoUrl),
      sharedPreferences.setBool(_keyIsLoggedIn, false),
    ]);
  }
  
  /// Save auth token (if needed for API calls).
  Future<void> saveAuthToken(String token) async {
    await sharedPreferences.setString('auth_token', token);
  }
  
  /// Get auth token.
  Future<String?> getAuthToken() async {
    return sharedPreferences.getString('auth_token');
  }
  
  /// Clear auth token.
  Future<void> clearAuthToken() async {
    await sharedPreferences.remove('auth_token');
  }
  
  /// Check if this is first launch.
  Future<bool> isFirstLaunch() async {
    final isFirst = sharedPreferences.getBool('is_first_launch') ?? true;
    if (isFirst) {
      await sharedPreferences.setBool('is_first_launch', false);
    }
    return isFirst;
  }
}