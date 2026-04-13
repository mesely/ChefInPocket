import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<Recipe> _recipeFuture;
  bool _didLoad = false;
  bool _isSaved = false;
  bool _isSaving = false;

  String get _slug {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String && arguments.isNotEmpty) {
      return arguments;
    }

    if (arguments is Map && arguments['slug'] is String) {
      return arguments['slug'] as String;
    }

    return 'menemen';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _recipeFuture = _loadRecipe();
      _didLoad = true;
    }
  }

  Future<Recipe> _loadRecipe() async {
    final results = await Future.wait([
      ApiService.instance.fetchRecipe(_slug),
      ApiService.instance.fetchSavedRecipes(),
    ]);
    final recipe = results[0] as Recipe;
    final savedRecipes = results[1] as List<SavedRecipe>;
    _isSaved = savedRecipes.any((item) => item.recipeSlug == recipe.id);
    return recipe;
  }

  Future<void> _toggleSaved(Recipe recipe) async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isSaved) {
        await ApiService.instance.removeSavedRecipe(recipe.id);
      } else {
        await ApiService.instance.saveRecipe(SavedRecipe.fromRecipe(recipe));
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaved = !_isSaved;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? 'Recipe saved.' : 'Recipe removed from saved.'),
          duration: const Duration(seconds: 1),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Column(
              children: [
                Text('Recipe could not be loaded.', style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _recipeFuture = _loadRecipe();
                  }),
                  child: const Text('Retry'),
                ),
              ],
            );
          }

          final recipe = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: _RecipeImage(imageUrl: recipe.imageUrl),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: _isSaving ? null : () => _toggleSaved(recipe),
                        icon: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: _isSaved ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(recipe.title, style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoTag(label: recipe.duration),
                  InfoTag(label: '${recipe.servings} servings'),
                  ...recipe.tags.map((tag) => InfoTag(label: tag)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(recipe.description, style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.lg),
              const AppSectionHeader(label: 'Recipe Tools'),
              const SizedBox(height: AppSpacing.sm),
              _ToolCard(
                icon: Icons.scale_outlined,
                title: 'Adjust servings',
                subtitle: 'Update ingredient amounts',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.servingScale,
                  arguments: recipe.id,
                ),
              ),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.tune_outlined,
                title: 'Customize ingredients',
                subtitle: 'Replace or remove elements',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.customizeIngredients,
                  arguments: recipe.id,
                ),
              ),
              const SizedBox(height: 12),
              _ToolCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Ask Chef AI',
                subtitle: 'Get help and suggestions',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.aiChat,
                  arguments: {
                    'slug': recipe.id,
                    'context': recipe.title,
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cookingSteps,
                  arguments: recipe.id,
                ),
                child: const Text('Start Cooking'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  const _RecipeImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset('assets/images/recipe-hero.jpg', fit: BoxFit.cover);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/images/recipe-hero.jpg', fit: BoxFit.cover);
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
      ),
    );
  }
}
