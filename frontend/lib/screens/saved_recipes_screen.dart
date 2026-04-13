import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  late Future<List<SavedRecipe>> _savedFuture;
  List<SavedRecipe> _savedRecipes = const [];
  bool _loadedSaved = false;

  @override
  void initState() {
    super.initState();
    _savedFuture = _loadSavedRecipes();
  }

  Future<List<SavedRecipe>> _loadSavedRecipes() async {
    final saved = await ApiService.instance.fetchSavedRecipes();
    _savedRecipes = saved;
    _loadedSaved = true;
    return saved;
  }

  Future<void> _removeSaved(SavedRecipe recipe) async {
    try {
      await ApiService.instance.removeSavedRecipe(recipe.recipeSlug);
      if (!mounted) {
        return;
      }

      setState(() {
        _savedRecipes = _savedRecipes
            .where((item) => item.recipeSlug != recipe.recipeSlug)
            .toList();
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      currentRoute: AppRoutes.savedRecipes,
      showBottomNav: false,
      child: FutureBuilder<List<SavedRecipe>>(
        future: _savedFuture,
        builder: (context, snapshot) {
          final savedRecipes = _loadedSaved ? _savedRecipes : snapshot.data ?? const [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppSpacing.sm),
              Text('Saved Recipes', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.md),
              if (snapshot.connectionState == ConnectionState.waiting && !_loadedSaved)
                const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text('Saved recipes could not be loaded.', style: AppTextStyles.body)
              else if (savedRecipes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('No saved recipes yet', style: AppTextStyles.title),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Save recipes from Community or Recipe Detail to see them here.',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...savedRecipes.map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SavedRecipeCard(
                      recipe: recipe,
                      onRemove: () => _removeSaved(recipe),
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

class _SavedRecipeCard extends StatelessWidget {
  const _SavedRecipeCard({
    required this.recipe,
    required this.onRemove,
  });

  final SavedRecipe recipe;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Text(recipe.author.substring(1, 2).toUpperCase()),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.author,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(recipe.role, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.bookmark, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.recipeDetail,
                  arguments: recipe.recipeSlug,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  recipe.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/community-bowl.jpg',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.recipeDetail,
                  arguments: recipe.recipeSlug,
                );
              },
              child: Text(recipe.title, style: AppTextStyles.title),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(recipe.description, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
