import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  Future<void> _deleteRecipe(BuildContext context, Recipe recipe) async {
    try {
      await ApiService.instance.deleteRecipe(recipe.id);
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: StreamBuilder<List<Recipe>>(
        stream: ApiService.instance.watchMyRecipes(),
        builder: (context, snapshot) {
          final recipes = snapshot.data ?? const <Recipe>[];

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
              if (snapshot.connectionState == ConnectionState.waiting &&
                  recipes.isEmpty)
                const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text('Could not load your recipes.', style: AppTextStyles.body)
              else if (recipes.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.restaurant_menu_outlined,
                        size: 40,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "You haven't shared any recipes yet.",
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Post a recipe to see it here.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.addRecipe),
                        child: const Text('Post a Recipe'),
                      ),
                    ],
                  ),
                ),
              ] else
                ...recipes.map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MyRecipeCard(
                      recipe: recipe,
                      onEdit: () => Navigator.pushNamed(
                        context,
                        AppRoutes.addRecipe,
                        arguments: recipe.id,
                      ),
                      onDelete: () => _deleteRecipe(context, recipe),
                    ),
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
  const _MyRecipeCard({
    required this.recipe,
    required this.onEdit,
    required this.onDelete,
  });

  final Recipe recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: recipe.id,
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
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
                  const SizedBox(height: 4),
                  Text(recipe.subtitle, style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    recipe.duration,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
