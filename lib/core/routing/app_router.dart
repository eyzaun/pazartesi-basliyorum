import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/habits/presentation/screens/create_habit_screen.dart';
import '../../features/habits/presentation/screens/edit_habit_screen.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/habits/presentation/screens/home_screen.dart';

/// Central routing configuration for the application.
/// All route names and navigation logic are defined here.
class AppRouter {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String habitCreate = '/habit/create';
  static const String habitDetail = '/habit/detail';
  static const String habitEdit = '/habit/edit';
  static const String statistics = '/statistics';
  static const String social = '/social';
  static const String profile = '/profile';

  /// Generate routes based on route settings.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case habitCreate:
        return MaterialPageRoute(builder: (_) => const CreateHabitScreen());

      case habitDetail:
        final habitId = settings.arguments as String?;
        if (habitId == null) {
          return _errorRoute('Habit ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => HabitDetailScreen(habitId: habitId),
        );

      case habitEdit:
        final habitId = settings.arguments as String?;
        if (habitId == null) {
          return _errorRoute('Habit ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => EditHabitScreen(habitId: habitId),
        );

      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  /// Error route for undefined routes.
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
