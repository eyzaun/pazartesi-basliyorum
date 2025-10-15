import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../providers/auth_provider.dart';

/// Splash screen shown on app startup.
/// Checks authentication state and navigates accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for minimum splash screen duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('onboarding_seen') ?? false;

    // Check auth state
    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (!mounted || _navigated) return;
        _navigated = true;

        if (user != null) {
          // Check if user needs to complete username selection (Google sign-in)
          if (user.username.isEmpty) {
            // User needs to select username -> go to username selection
            Navigator.of(context).pushReplacementNamed(
              AppRouter.usernameSelection,
              arguments: {
                'userId': user.id,
                'email': user.email,
                'photoUrl': user.photoUrl,
              },
            );
          } else {
            // User authenticated and complete -> go to home
            Navigator.of(context).pushReplacementNamed(AppRouter.home);
          }
        } else if (hasSeenOnboarding) {
          // Seen onboarding -> go to welcome
          Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
        } else {
          // First time -> show onboarding
          Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
        }
      },
      loading: () {
        // Still loading after 2 seconds
        if (!mounted || _navigated) return;
        _navigated = true;

        if (hasSeenOnboarding) {
          Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
        }
      },
      error: (error, stack) {
        if (!mounted || _navigated) return;
        _navigated = true;

        if (hasSeenOnboarding) {
          Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo (emoji for now)
            const Text(
              '📅',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Tagline
            Text(
              'Alışkanlıklarını takip et',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
