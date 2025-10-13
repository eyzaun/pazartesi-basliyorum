import 'package:flutter/material.dart';

/// App color constants for consistent theming.
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9B95FF);
  static const Color primaryDark = Color(0xFF4A42CC);
  
  // Secondary colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF3);
  static const Color secondaryDark = Color(0xFF00A896);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Dark theme colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color dividerDark = Color(0xFF424242);
  
  // Habit colors (for customization)
  static const List<Color> habitColors = [
    Color(0xFF6C63FF), // Purple
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFD93D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFF38181), // Pink
    Color(0xFFAA96DA), // Lavender
    Color(0x0fcbbad3), // Light Pink
  ];
  
  // Category colors
  static const Map<String, Color> categoryColors = {
    'Sağlık': Color(0xFFFF6B6B),
    'Spor': Color(0xFF4ECDC4),
    'Üretkenlik': Color(0xFFFF9800),
    'Sosyal': Color(0xFFAA96DA),
    'Öğrenme': Color(0xFF4CAF50),
    'Mali': Color(0xFF2196F3),
    'Kişisel Gelişim': Color(0xFFF38181),
    'Yaratıcılık': Color(0xFFFFD93D),
    'Diğer': Color(0xFF9E9E9E),
  };
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF81C784)],
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, Color(0xFFFFB74D)],
  );
  
  // Helper methods
  static Color getHabitColor(int index) {
    return habitColors[index % habitColors.length];
  }
  
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? categoryColors['Diğer']!;
  }
  
  static Color hexToColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return primary;
    }
  }
  
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}