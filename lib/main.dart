import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:universal_html/html.dart' as html;

import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/sync_queue_item.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web cache bypass for auto-update
  if (kIsWeb) {
    const currentVersion = '1.1.0'; // Update this with each release
    final storedVersion = html.window.localStorage['app_version'];
    if (storedVersion != currentVersion) {
      html.window.localStorage['app_version'] = currentVersion;
      html.window.location.reload();
    }
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(SyncQueueItemAdapter());

  // Initialize timezone database for notifications
  tz.initializeTimeZones();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize notifications
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    await notificationService.requestPermissions();

    // Initialize push notifications
    final pushNotificationService = ref.read(pushNotificationServiceProvider);
    await pushNotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pazartesi Başlıyorum',
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''),
        Locale('en', ''),
      ],
      locale: const Locale('tr'), // Default Turkish

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Routing
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
