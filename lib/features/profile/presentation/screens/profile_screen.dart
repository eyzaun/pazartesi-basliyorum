import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile screen showing user information and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Giriş Yapılmadı',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profilinizi görüntülemek için giriş yapın',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
                    },
                    child: Text(l10n.signIn),
                  ),
                ],
              ),
            );
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.displayName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        user.displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Username
                      Text(
                        '@${user.username}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Email
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Statistics Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İstatistikler',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            icon: Icons.check_circle_outline,
                            value: '0',
                            label: 'Tamamlama',
                          ),
                          _buildStatItem(
                            context,
                            icon: Icons.local_fire_department,
                            value: '0',
                            label: 'Mevcut Seri',
                          ),
                          _buildStatItem(
                            context,
                            icon: Icons.star_outline,
                            value: '0',
                            label: 'En Uzun Seri',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Settings Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Tema'),
                      subtitle: const Text('Sistem varsayılanı'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Implement theme selection
                        context.showSnackBar('Yakında eklenecek');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Dil'),
                      subtitle: const Text('Türkçe'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Implement language selection
                        context.showSnackBar('Yakında eklenecek');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('Bildirimler'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Implement notifications settings
                        context.showSnackBar('Yakında eklenecek');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // About Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Hakkında'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Yardım ve Destek'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.showSnackBar('Yakında eklenecek');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Sign Out Button
              ElevatedButton.icon(
                onPressed: () => _signOut(context, ref),
                icon: const Icon(Icons.logout),
                label: Text(l10n.signOut),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Pazartesi Başlıyorum',
      applicationVersion: '1.0.0',
      applicationIcon: const Text('📅', style: TextStyle(fontSize: 40)),
      children: [
        const Text(
          'Alışkanlıklarını takip et, hedeflerine ulaş!\n\n'
          'Bu uygulama ile günlük alışkanlıklarınızı kolayca takip edebilir, '
          'ilerlemenizi görselleştirebilir ve hedeflerinize ulaşabilirsiniz.',
        ),
      ],
    );
  }
  
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true && context.mounted) {
      final result = await ref.read(authRepositoryProvider).signOut();
      
      if (result is Success && context.mounted) {
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.welcome,
            (route) => false,
          ),
        );
      }
    }
  }
}