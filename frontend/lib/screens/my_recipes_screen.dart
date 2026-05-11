import 'package:flutter/material.dart';

import '../models/firestore_models.dart';
import '../routes/app_routes.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: StreamBuilder<List<RecipeDoc>>(
        stream: FirestoreService.instance.streamMyRecipes(),
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppSpacing.sm),
              Text('My Recipes', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Recipes you have shared with the community.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text('Could not load your recipes.', style: AppTextStyles.body)
              else if ((snapshot.data ?? []).isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "You haven't shared any recipes yet.",
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.addRecipe),
                        child: const Text('Share a Recipe'),
                      ),
                    ],
                  ),
                ),
              ] else
                ...(snapshot.data!).map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _MyRecipeCard(recipe: recipe),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MyRecipeCard extends StatelessWidget {
  const _MyRecipeCard({required this.recipe});

  final RecipeDoc recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: recipe.imageUrl.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, err, stack) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (recipe.cuisine.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(recipe.cuisine, style: AppTextStyles.caption),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.duration} · ${recipe.servings} servings',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.danger,
              ),
              onPressed: () async {
                await FirestoreService.instance.deleteRecipe(recipe.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.warmAccent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.restaurant_menu,
        size: 32,
        color: AppColors.textMuted,
      ),
    );
  }
}
