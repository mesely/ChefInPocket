import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class RecipeResultsScreen extends StatefulWidget {
  const RecipeResultsScreen({super.key});

  @override
  State<RecipeResultsScreen> createState() => _RecipeResultsScreenState();
}

class _RecipeResultsScreenState extends State<RecipeResultsScreen> {
  late Future<List<Recipe>> _recipesFuture;
  bool _didLoad = false;
  String _activeFilter = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _recipesFuture = _loadRecipes();
      _didLoad = true;
    }
  }

  Future<List<Recipe>> _loadRecipes() async {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    List<Recipe> recipes;
    if (arguments is Map && arguments['slugs'] is List) {
      final slugs =
          (arguments['slugs'] as List).map((item) => item.toString()).toList();
      recipes = await ApiService.instance.fetchRecipesBySlugs(slugs);
    } else {
      recipes = await ApiService.instance.fetchRecipes();
    }

    if (arguments is Map && arguments['cuisine'] is String) {
      final cuisine = (arguments['cuisine'] as String).toLowerCase();
      final filtered = recipes.where((r) {
        return '${r.title} ${r.subtitle} ${r.tags.join(' ')}'
            .toLowerCase()
            .contains(cuisine);
      }).toList();
      if (filtered.isNotEmpty) return filtered;
    }

    return recipes;
  }

  List<Recipe> _filteredRecipes(List<Recipe> recipes) {
    if (_activeFilter == 'All') return recipes;

    final query = _activeFilter.toLowerCase();
    final filtered = recipes.where((recipe) {
      final haystack =
          '${recipe.title} ${recipe.subtitle} ${recipe.tags.join(' ')}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();

    return filtered.isEmpty ? recipes : filtered;
  }

  String get _cuisineTitle {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map && arguments['cuisine'] is String) {
      return arguments['cuisine'] as String;
    }
    return 'Matching Recipes';
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Quick', 'Easy'];

    return ChefPage(
      child: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
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
                Text('Recipes could not be loaded.', style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _recipesFuture = _loadRecipes();
                  }),
                  child: const Text('Retry'),
                ),
              ],
            );
          }

          final recipes = _filteredRecipes(snapshot.data!);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppSpacing.sm),
              Text(_cuisineTitle, style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${snapshot.data!.length} recipes found',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filters.map((filter) {
                  return InfoChip(
                    label: filter,
                    isActive: _activeFilter == filter,
                    onTap: () {
                      setState(() {
                        _activeFilter = filter;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (recipes.isEmpty)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'No matching recipes yet. Try selecting eggs and tomato.',
                      style: AppTextStyles.body,
                    ),
                  ),
                )
              else
                ...recipes.map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RecipeResultCard(recipe: recipe),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

String _recipeEmoji(Recipe recipe) {
  final cuisine = recipe.tags
      .firstWhere(
        (t) => ['Turkish', 'Italian', 'French', 'Healthy', 'Athlete', 'Soup', 'Salad', 'Breakfast', 'Pizza', 'Pasta', 'Grilled']
            .contains(t),
        orElse: () => '',
      )
      .toLowerCase();
  switch (cuisine) {
    case 'turkish': return '🇹🇷';
    case 'italian': return '🍝';
    case 'french': return '🥐';
    case 'healthy': return '🥗';
    case 'athlete': return '💪';
    case 'soup': return '🍲';
    case 'salad': return '🥬';
    case 'breakfast': return '🍳';
    case 'pizza': return '🍕';
    case 'pasta': return '🍝';
    case 'grilled': return '🔥';
    default: return '🍽️';
  }
}

class _RecipeResultCard extends StatelessWidget {
  const _RecipeResultCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: recipe.id,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _recipeEmoji(recipe),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(recipe.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(
              recipe.duration,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
