import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/preferences_provider.dart';
import '../routes/app_routes.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prefs = context.watch<PreferencesProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final fullName = user.displayName ?? 'Chef';
    final email = user.email ?? '';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C';
    final handle = '@${email.split('@').first}';

    return ChefPage(
      currentRoute: AppRoutes.profile,
      showBottomNav: true,
      child: StreamBuilder(
        stream: FirestoreService.instance.streamMyRecipes(),
        builder: (context, myRecipesSnap) {
          return StreamBuilder(
            stream: FirestoreService.instance.streamSavedRecipes(),
            builder: (context, savedSnap) {
              final myCount = myRecipesSnap.data?.length ?? 0;
              final savedCount = savedSnap.data?.length ?? 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4D8),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(initial, style: AppTextStyles.display),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(fullName, style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Text(handle, style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Text(email, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Metric(value: '$savedCount', label: 'saved'),
                      const SizedBox(width: 24),
                      _Metric(value: '$myCount', label: 'recipes'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ProfileMenuTile(
                    title: 'My Recipes',
                    subtitle: 'Recipes you have shared',
                    icon: Icons.menu_book_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.myRecipes),
                  ),
                  const SizedBox(height: 12),
                  ProfileMenuTile(
                    title: 'Saved Recipes',
                    subtitle: 'Bookmarked recipes',
                    icon: Icons.bookmark_outline,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.savedRecipes),
                  ),
                  const SizedBox(height: 12),
                  ProfileMenuTile(
                    title: 'Grocery List',
                    subtitle: 'Your shopping list',
                    icon: Icons.shopping_basket_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.groceryList),
                  ),
                  const SizedBox(height: 12),
                  ProfileMenuTile(
                    title: prefs.isDark ? 'Light Mode' : 'Dark Mode',
                    subtitle: 'Toggle app theme',
                    icon: prefs.isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    onTap: () => prefs.toggleTheme(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton(
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.onboarding,
                          (_) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                    child: const Text('Log Out'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
