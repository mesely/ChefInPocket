import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class BrowseCuisineScreen extends StatefulWidget {
  const BrowseCuisineScreen({super.key});

  @override
  State<BrowseCuisineScreen> createState() => _BrowseCuisineScreenState();
}

class _BrowseCuisineScreenState extends State<BrowseCuisineScreen> {
  static const _cuisines = [
    _CuisineEntry('🇹🇷', 'Turkish', 'Menemen, köfte, kısır and more'),
    _CuisineEntry('🍝', 'Italian', 'Pasta, pizza, caprese'),
    _CuisineEntry('🥐', 'French', 'Omelette, ratatouille, soups'),
    _CuisineEntry('🥗', 'Healthy', 'Bowls, salads, clean eating'),
    _CuisineEntry('💪', 'Athlete', 'High protein, post-workout meals'),
    _CuisineEntry('🌍', 'Other', 'Browse all recipes'),
  ];

  void _goToRecipes(String cuisine) {
    Navigator.pushNamed(
      context,
      AppRoutes.recipeResults,
      arguments: {'cuisine': cuisine},
    );
  }

  void _goToIngredientPicker(String cuisine) {
    Navigator.pushNamed(
      context,
      AppRoutes.ingredientPicker,
      arguments: cuisine,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppBackButton(),
          const SizedBox(height: AppSpacing.sm),
          Text('Cuisines', style: AppTextStyles.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pick a cuisine to browse recipes or match with your pantry.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._cuisines.map(
            (cuisine) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CuisineTile(
                cuisine: cuisine,
                onBrowse: () => _goToRecipes(cuisine.title),
                onMatch: () => _goToIngredientPicker(cuisine.title),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuisineTile extends StatelessWidget {
  const _CuisineTile({
    required this.cuisine,
    required this.onBrowse,
    required this.onMatch,
  });

  final _CuisineEntry cuisine;
  final VoidCallback onBrowse;
  final VoidCallback onMatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(cuisine.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cuisine.title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(cuisine.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onBrowse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Browse',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onMatch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'By pantry',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CuisineEntry {
  const _CuisineEntry(this.emoji, this.title, this.subtitle);
  final String emoji;
  final String title;
  final String subtitle;
}
