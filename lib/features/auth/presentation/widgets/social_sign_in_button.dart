import 'package:flutter/material.dart';

/// Custom button for social sign-in providers.
class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.text,
    required this.onPressed,
    required this.provider,
    super.key,
    this.isLoading = false,
  });

  /// Factory for Google sign-in button.
  factory SocialSignInButton.google({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialSignInButton(
      text: text,
      onPressed: onPressed,
      provider: SocialProvider.google,
      isLoading: isLoading,
    );
  }

  /// Factory for Apple sign-in button.
  factory SocialSignInButton.apple({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialSignInButton(
      text: text,
      onPressed: onPressed,
      provider: SocialProvider.apple,
      isLoading: isLoading,
    );
  }

  /// Factory for Facebook sign-in button.
  factory SocialSignInButton.facebook({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialSignInButton(
      text: text,
      onPressed: onPressed,
      provider: SocialProvider.facebook,
      isLoading: isLoading,
    );
  }
  final String text;
  final VoidCallback? onPressed;
  final SocialProvider provider;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(
          color: provider.borderColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(provider.iconColor),
              ),
            )
          else
            _buildIcon(),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: provider.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (provider) {
      case SocialProvider.google:
        return _GoogleIcon();
      case SocialProvider.apple:
        return Icon(Icons.apple, size: 24, color: provider.iconColor);
      case SocialProvider.facebook:
        return Icon(Icons.facebook, size: 24, color: provider.iconColor);
    }
  }
}

/// Social provider enum.
enum SocialProvider {
  google(
    iconColor: Color(0xFF4285F4),
    textColor: Color(0xFF000000),
    borderColor: Color(0xFFDDDDDD),
  ),
  apple(
    iconColor: Color(0xFF000000),
    textColor: Color(0xFF000000),
    borderColor: Color(0xFF000000),
  ),
  facebook(
    iconColor: Color(0xFF1877F2),
    textColor: Color(0xFF1877F2),
    borderColor: Color(0xFF1877F2),
  );

  const SocialProvider({
    required this.iconColor,
    required this.textColor,
    required this.borderColor,
  });

  final Color iconColor;
  final Color textColor;
  final Color borderColor;
}

/// Custom Google icon widget.
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4285F4),
            Color(0xFF34A853),
            Color(0xFFFBBC05),
            Color(0xFFEA4335),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
