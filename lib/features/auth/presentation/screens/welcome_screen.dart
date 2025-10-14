import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/result.dart';
import '../providers/auth_provider.dart';

/// Welcome screen shown to unauthenticated users.
/// Provides options to sign in, sign up, or continue as guest.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // App Logo
              const Center(
                child: Text(
                  '📅',
                  style: TextStyle(fontSize: 100),
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              Text(
                l10n.appName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Tagline
              Text(
                l10n.welcomeTitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Email Sign In Button (Primary)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.signIn);
                  },
                  icon: const Icon(Icons.email_outlined, size: 20),
                  label: const Text(
                    'E-posta ile Giriş Yap',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Show loading state
                    ref.read(authLoadingProvider.notifier).state = true;
                    
                    try {
                      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
                      
                      if (result is Success) {
                        // Navigate to home on success
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed(AppRouter.home);
                        }
                      } else if (result is Failure) {
                        // Show error message
                        final failure = result as Failure;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google girişi başarısız: ${failure.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Show error message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Bir hata oluştu: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      ref.read(authLoadingProvider.notifier).state = false;
                    }
                  },
                  icon: Image.asset(
                    'assets/icons/google_logo.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.g_mobiledata, size: 24);
                    },
                  ),
                  label: const Text(
                    'Google ile Giriş Yap',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hesabın yok mu? ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRouter.signUp);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: Text(
                      'Kayıt Ol',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Continue as Guest Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRouter.home);
                },
                child: Text(
                  l10n.continueAsGuest,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
