import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class AppEntryScreen extends StatelessWidget {
  const AppEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.pageBackground(context),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    return const OnboardingScreen();
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.pageBackground(context),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const OnboardingScreen();
    }

    return child;
  }
}
