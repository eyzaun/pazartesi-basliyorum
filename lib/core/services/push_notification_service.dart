import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

/// Push notification service for Firebase Cloud Messaging.
class PushNotificationService {
  PushNotificationService(this._messaging, this._firestore, this._auth, this._localNotifications);

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  final NotificationService _localNotifications;

  bool _initialized = false;

  /// Initialize push notifications.
  Future<void> initialize() async {
    if (_initialized) return;

    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Push notifications authorized');

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }

      // Handle token refresh
      _messaging.onTokenRefresh.listen(_saveFCMToken);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

      // Check for message that opened app
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage);
      }

      _initialized = true;
    }
  }

  /// Save FCM token to Firestore.
  Future<void> _saveFCMToken(String token) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });

    print('FCM token saved: $token');
  }

  /// Handle foreground message.
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');

    // Show local notification
    if (message.notification != null) {
      _localNotifications.showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'Bildirim',
        body: message.notification!.body ?? '',
      );
    }
  }

  /// Handle message tap.
  void _handleMessageTap(RemoteMessage message) {
    print('Message tapped: ${message.notification?.title}');
    // TODO: Navigate to appropriate screen based on data
  }

  /// Subscribe to topic.
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

// Provider
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(
    FirebaseMessaging.instance,
    FirebaseFirestore.instance,
    firebase_auth.FirebaseAuth.instance,
    ref.watch(notificationServiceProvider),
  );
});
