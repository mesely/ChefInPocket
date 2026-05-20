import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../providers/auth_provider.dart';
import '../providers/preferences_provider.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesProvider = context.watch<PreferencesProvider>();

    return ChefPage(
      currentRoute: AppRoutes.profile,
      showBottomNav: true,
      child: StreamBuilder<UserProfile?>(
        stream: ApiService.instance.watchProfile(),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting &&
              !profileSnapshot.hasData) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (!profileSnapshot.hasData) {
            return Text(
              'Profile could not be loaded.',
              style: AppTextStyles.body,
            );
          }

          final profile = profileSnapshot.data!;

          return StreamBuilder<List<SavedRecipe>>(
            stream: ApiService.instance.watchSavedRecipes(),
            builder: (context, savedSnapshot) {
              final savedCount =
                  savedSnapshot.data?.length ?? profile.savedRecipes;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4D8),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Center(
                            child: Text(
                              _profileEmoji(profile.gender),
                              style: const TextStyle(fontSize: 34),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(profile.fullName, style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Text(profile.username, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CompactMetric(value: '$savedCount', label: 'saved'),
                      const SizedBox(width: 24),
                      _CompactMetric(
                        value: '${profile.publishedRecipes}',
                        label: 'recipes',
                      ),
                      const SizedBox(width: 24),
                      _CompactMetric(
                        value: '${profile.cookedMeals}',
                        label: 'cooked',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ProfileRow(label: 'Name', value: profile.fullName),
                  const SizedBox(height: 10),
                  _ProfileRow(label: 'Email', value: profile.email),
                  const SizedBox(height: 10),
                  _ProfileRow(
                    label: 'Theme',
                    value: preferencesProvider.isDarkMode ? 'Dark' : 'Light',
                    trailing: Switch(
                      value: preferencesProvider.isDarkMode,
                      onChanged: preferencesProvider.setDarkMode,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProfileMenuTile(
                      title: 'Saved Recipes',
                      subtitle: 'Open your personal collection',
                      icon: Icons.bookmark_outline,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.savedRecipes),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProfileMenuTile(
                      title: 'My Recipes',
                      subtitle: 'Edit or delete your own recipes',
                      icon: Icons.menu_book_outlined,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.myRecipes),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProfileMenuTile(
                      title: 'Grocery List',
                      subtitle: 'Keep your ingredients in sync',
                      icon: Icons.shopping_cart_checkout_outlined,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.groceryList),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.appEntry,
                        (route) => false,
                      );
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

  String _profileEmoji(String gender) {
    switch (gender) {
      case 'female':
        return '👩';
      case 'male':
        return '👨';
      default:
        return '🧑';
    }
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(value, style: AppTextStyles.body)),
          if (trailing != null) ...[trailing!],
        ],
      ),
    );
  }
}
