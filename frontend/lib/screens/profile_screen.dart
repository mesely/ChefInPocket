import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<_ProfileData> _loadProfile() async {
    final results = await Future.wait([
      ApiService.instance.fetchProfile(),
      ApiService.instance.fetchContent(),
      ApiService.instance.fetchSavedRecipes(),
    ]);

    final profile = results[0] as UserProfile;
    final content = results[1] as AppContent;
    final saved = results[2] as List<SavedRecipe>;

    return _ProfileData(
      profile: profile,
      menu: content.profileMenu.where((item) => item.routeName != null).toList(),
      savedCount: saved.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      currentRoute: AppRoutes.profile,
      showBottomNav: true,
      child: FutureBuilder<_ProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Text('Profile could not be loaded.', style: AppTextStyles.body);
          }

          final data = snapshot.data!;
          final username = '@${data.profile.email.split('@').first}';
          final initial = data.profile.fullName.characters.first.toUpperCase();

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
                    Text(data.profile.fullName, style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    Text(username, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CompactMetric(value: '${data.savedCount}', label: 'saved'),
                  const SizedBox(width: 24),
                  _CompactMetric(
                    value: '${data.profile.publishedRecipes}',
                    label: 'recipes',
                  ),
                  const SizedBox(width: 24),
                  _CompactMetric(
                    value: '${data.profile.cookedMeals}',
                    label: 'cooked',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(data.profile.email, style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.md),
              ...data.menu.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProfileMenuTile(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    onTap: () {
                      // Reroute My Recipes from /add-recipe to /my-recipes
                      final route = item.routeName == AppRoutes.addRecipe
                          ? AppRoutes.myRecipes
                          : item.routeName!;
                      Navigator.pushNamed(context, route);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.onboarding,
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
      ),
    );
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

class _ProfileData {
  const _ProfileData({
    required this.profile,
    required this.menu,
    required this.savedCount,
  });

  final UserProfile profile;
  final List<ProfileMenuEntry> menu;
  final int savedCount;
}
