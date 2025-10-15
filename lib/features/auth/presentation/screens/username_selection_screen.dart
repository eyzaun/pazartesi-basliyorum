import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/result.dart';
import '../providers/auth_provider.dart';
import '../providers/username_check_provider.dart';

/// Screen for selecting a username after Google sign-in.
class UsernameSelectionScreen extends ConsumerStatefulWidget {
  const UsernameSelectionScreen({
    required this.email,
    required this.photoUrl,
    required this.userId,
    super.key,
  });

  final String email;
  final String? photoUrl;
  final String userId;

  @override
  ConsumerState<UsernameSelectionScreen> createState() =>
      _UsernameSelectionScreenState();
}

class _UsernameSelectionScreenState
    extends ConsumerState<UsernameSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Suggest a username based on email
    final baseUsername = widget.email.split('@')[0];
    _usernameController.text = baseUsername;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkAndSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();

      // Check if username is available
      final isAvailable =
          await ref.read(usernameCheckProvider(username).future);

      if (!isAvailable && mounted) {
        context.showErrorSnackBar(
          'Bu kullanıcı adı kullanımda. Lütfen başka bir tane deneyin.',
        );
        setState(() => _isLoading = false);
        return;
      }

      // Complete Google sign-in with selected username
      final completeResult =
          await ref.read(authRepositoryProvider).completeGoogleSignIn(
                userId: widget.userId,
                email: widget.email,
                username: username,
                photoUrl: widget.photoUrl,
              );

      if (!mounted) return;

      switch (completeResult) {
        case Success():
          // Navigate to home and remove all previous routes
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.home,
            (route) => false,
          );
        case Failure(:final message):
          context.showErrorSnackBar(message);
          setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Bir hata oluştu: ${e.toString()}');
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kullanıcı adı gerekli';
    }

    final username = value.trim();

    if (username.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalı';
    }

    if (username.length > 30) {
      return 'Kullanıcı adı en fazla 30 karakter olmalı';
    }

    // Only allow alphanumeric and underscore
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Sadece harf, rakam ve alt çizgi kullanabilirsiniz';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Profile photo
                if (widget.photoUrl != null)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(widget.photoUrl!),
                    ),
                  )
                else
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        widget.email.isNotEmpty
                            ? widget.email[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Welcome text
                Text(
                  'Hoş Geldiniz!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  widget.email,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Instruction text
                Text(
                  'Lütfen bir kullanıcı adı seçin',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    hintText: 'kullaniciadi',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText:
                        'Harf, rakam ve alt çizgi kullanabilirsiniz (3-30 karakter)',
                    helperMaxLines: 2,
                  ),
                  validator: _validateUsername,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _checkAndSubmit(),
                  enabled: !_isLoading,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 24),

                // Submit button
                FilledButton(
                  onPressed: _isLoading ? null : _checkAndSubmit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Devam Et',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kullanıcı adınız arkadaşlarınız tarafından görülecektir.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
