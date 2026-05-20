import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../providers/app_data_provider.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Recipe> _suggestions = const [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _showSuggestions = false;
      });
      return;
    }

    final matches = context
        .read<AppDataProvider>()
        .searchRecipes(query)
        .take(5)
        .toList();
    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty;
    });
  }

  void _openRecipe(Recipe recipe) {
    Navigator.pushNamed(context, AppRoutes.recipeDetail, arguments: recipe.id);
  }

  void _submitSearch(String value) {
    final matches = context.read<AppDataProvider>().searchRecipes(value);
    setState(() {
      _showSuggestions = false;
    });

    if (matches.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No recipe found for "$value".')));
      return;
    }

    _openRecipe(matches.first);
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AppDataProvider>();

    return ChefPage(
      currentRoute: AppRoutes.home,
      showBottomNav: true,
      child: StreamBuilder<UserProfile?>(
        stream: ApiService.instance.watchProfile(),
        builder: (context, snapshot) {
          if (dataProvider.isLoading || dataProvider.content == null) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (dataProvider.errorMessage != null) {
            return _ErrorState(
              message: 'Home data could not be loaded.',
              onRetry: () => context.read<AppDataProvider>().refresh(),
            );
          }

          final profile = snapshot.data;
          final content = dataProvider.content!;
          final recipes = dataProvider.recipes;
          final daysSinceEpoch =
              DateTime.now().millisecondsSinceEpoch ~/ 86400000;
          final featuredRecipe = recipes.isEmpty
              ? null
              : recipes[daysSinceEpoch % recipes.length];
          final firstName = profile?.fullName.split(' ').first ?? 'Chef';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning, $firstName', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.xs),
              Text('What are you cooking today?', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.md),
              AppSearchField(
                hint: 'Search recipes...',
                controller: _searchController,
                onSubmitted: _submitSearch,
              ),
              if (_showSuggestions) ...[
                const SizedBox(height: 4),
                _SearchSuggestions(
                  suggestions: _suggestions,
                  onTap: (recipe) {
                    _searchController.text = recipe.title;
                    setState(() {
                      _showSuggestions = false;
                    });
                    _openRecipe(recipe);
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const AppSectionHeader(label: 'Cuisines'),
              const SizedBox(height: AppSpacing.sm),
              const _CuisineGrid(),
              const SizedBox(height: AppSpacing.lg),
              if (featuredRecipe != null) ...[
                _FeaturedRecipeCard(recipe: featuredRecipe),
                const SizedBox(height: AppSpacing.lg),
              ],
              const AppSectionHeader(label: 'Quick Access'),
              const SizedBox(height: AppSpacing.sm),
              ...content.quickAccess
                  .where((item) => item.routeName != AppRoutes.browseCuisine)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FeatureShortcutCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        icon: item.icon,
                        onTap: () =>
                            Navigator.pushNamed(context, item.routeName),
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

class _SearchSuggestions extends StatelessWidget {
  const _SearchSuggestions({required this.suggestions, required this.onTap});

  final List<Recipe> suggestions;
  final void Function(Recipe) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: suggestions.map((recipe) {
          return InkWell(
            onTap: () => onTap(recipe),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.mutedText(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(recipe.duration, style: AppTextStyles.caption),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CuisineGrid extends StatelessWidget {
  const _CuisineGrid();

  static const _items = [
    ('🇹🇷', 'Turkish'),
    ('🍝', 'Italian'),
    ('🥐', 'French'),
    ('🥗', 'Healthy'),
    ('💪', 'Athlete'),
    ('🌍', 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 420 ? 3 : 2;

        return GridView.builder(
          itemCount: _items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.62,
          ),
          itemBuilder: (context, index) {
            final item = _items[index];
            return InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.recipeResults,
                arguments: {'cuisine': item.$2},
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FeaturedRecipeCard extends StatelessWidget {
  const _FeaturedRecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface(context),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: AppColors.borderColor(context)),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.recipeDetail,
          arguments: recipe.id,
        ),
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/recipe-hero.jpg',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Featured for today', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(recipe.title, style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text(recipe.description, style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoTag(label: recipe.duration),
                      InfoTag(label: '${recipe.servings} servings'),
                      ...recipe.tags.take(2).map((tag) => InfoTag(label: tag)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
