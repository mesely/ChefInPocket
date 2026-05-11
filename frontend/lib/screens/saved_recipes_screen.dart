import 'package:flutter/material.dart';

import '../models/firestore_models.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: StreamBuilder<List<SavedRecipeDoc>>(
        stream: FirestoreService.instance.streamSavedRecipes(),
        builder: (context, snapshot) {
          final saved = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child:
                        Text('Saved Recipes', style: AppTextStyles.display),
                  ),
                  InfoChip(label: '${saved.length}', isActive: true),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Recipes you have bookmarked.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text('Could not load saved recipes.',
                    style: AppTextStyles.body)
              else if (saved.isEmpty)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_border, size: 36),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'No saved recipes yet.\nTap the bookmark icon on any recipe.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...saved.map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SavedRecipeCard(recipe: recipe),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SavedRecipeCard extends StatelessWidget {
  const _SavedRecipeCard({required this.recipe});

  final SavedRecipeDoc recipe;

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
                      errorBuilder: (_, err, stack) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (recipe.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(recipe.subtitle, style: AppTextStyles.caption),
                  ],
                  const SizedBox(height: 4),
                  Text(recipe.author, style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark,
                  color: AppColors.primary, size: 22),
              onPressed: () async {
                await FirestoreService.instance
                    .unsaveRecipe(recipe.recipeId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${recipe.title} removed from saved.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.warmAccent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.restaurant_menu,
          size: 32, color: AppColors.textMuted),
    );
  }
}
