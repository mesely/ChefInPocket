import 'package:flutter/material.dart';

import '../models/app_models.dart';
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
  late Future<_HomeData> _homeDataFuture;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Recipe> _allRecipes = const [];
  List<Recipe> _suggestions = const [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
    _loadAllRecipes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRecipes() async {
    try {
      final recipes = await ApiService.instance.fetchRecipes();
      if (mounted) {
        setState(() {
          _allRecipes = recipes;
        });
      }
    } catch (_) {}
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _showSuggestions = false;
      });
      return;
    }
    final matches = _allRecipes
        .where((r) => '${r.title} ${r.subtitle}'.toLowerCase().contains(query))
        .take(5)
        .toList();
    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty;
    });
  }

  Future<_HomeData> _loadHomeData() async {
    final results = await Future.wait([
      ApiService.instance.fetchContent(),
      ApiService.instance.fetchRecipes(),
      ApiService.instance.fetchProfile(),
    ]);

    final recipes = results[1] as List<Recipe>;
    final daysSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final todayIndex = recipes.isEmpty ? 0 : daysSinceEpoch % recipes.length;

    return _HomeData(
      content: results[0] as AppContent,
      featuredRecipe: recipes.isEmpty ? null : recipes[todayIndex],
      profile: results[2] as UserProfile,
    );
  }

  Future<void> _searchRecipe(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty || _isSearching) return;

    setState(() {
      _isSearching = true;
      _showSuggestions = false;
    });

    try {
      final recipes = _allRecipes.isNotEmpty
          ? _allRecipes
          : await ApiService.instance.fetchRecipes();

      final recipe = recipes.cast<Recipe?>().firstWhere(
            (item) =>
                item != null &&
                '${item.title} ${item.subtitle}'.toLowerCase().contains(normalizedQuery),
            orElse: () => null,
          );

      if (!mounted) return;

      if (recipe == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No recipe found for "$query".')),
        );
        return;
      }

      Navigator.pushNamed(context, AppRoutes.recipeDetail, arguments: recipe.id);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      currentRoute: AppRoutes.home,
      showBottomNav: true,
      child: FutureBuilder<_HomeData>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _ErrorState(
              message: 'Home data could not be loaded.',
              onRetry: () => setState(() {
                _homeDataFuture = _loadHomeData();
              }),
            );
          }

          final data = snapshot.data!;
          final firstName = data.profile.fullName.split(' ').first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning, $firstName', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.xs),
              Text('What are you cooking today?', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.md),
              AppSearchField(
                hint: _isSearching ? 'Searching...' : 'Search recipes...',
                controller: _searchController,
                onSubmitted: (v) {
                  setState(() => _showSuggestions = false);
                  _searchRecipe(v);
                },
              ),
              if (_showSuggestions) ...[
                const SizedBox(height: 4),
                _SearchSuggestions(
                  suggestions: _suggestions,
                  onTap: (recipe) {
                    _searchController.text = recipe.title;
                    setState(() => _showSuggestions = false);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.recipeDetail,
                      arguments: recipe.id,
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const AppSectionHeader(label: 'Cuisines'),
              const SizedBox(height: AppSpacing.sm),
              const _CuisineGrid(),
              const SizedBox(height: AppSpacing.lg),
              if (data.featuredRecipe != null) ...[
                _FeaturedRecipeCard(recipe: data.featuredRecipe!),
                const SizedBox(height: AppSpacing.lg),
              ],
              const AppSectionHeader(label: 'Quick Access'),
              const SizedBox(height: AppSpacing.sm),
              ...data.content.quickAccess
                  .where((item) => item.routeName != AppRoutes.browseCuisine)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FeatureShortcutCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        icon: item.icon,
                        onTap: () => Navigator.pushNamed(context, item.routeName),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                  const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
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
    _CuisineItem('🇹🇷', 'Turkish'),
    _CuisineItem('🍝', 'Italian'),
    _CuisineItem('🥐', 'French'),
    _CuisineItem('🥗', 'Healthy'),
    _CuisineItem('💪', 'Athlete'),
    _CuisineItem('🌍', 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: _items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];

        return GestureDetector(
          onTap: () {
            if (item.title == 'Other') {
              Navigator.pushNamed(context, AppRoutes.browseCuisine);
            } else {
              Navigator.pushNamed(
                context,
                AppRoutes.recipeResults,
                arguments: {'cuisine': item.title},
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  item.title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CuisineItem {
  const _CuisineItem(this.emoji, this.title);

  final String emoji;
  final String title;
}

class _FeaturedRecipeCard extends StatelessWidget {
  const _FeaturedRecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(recipe.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's pick", style: AppTextStyles.sectionLabel),
            const SizedBox(height: AppSpacing.xs),
            Text(recipe.title, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(recipe.description, style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.recipeDetail,
                arguments: recipe.id,
              ),
              child: const Text('Open Recipe'),
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
    return Center(
      child: Column(
        children: [
          Text(message, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.content,
    required this.featuredRecipe,
    required this.profile,
  });

  final AppContent content;
  final Recipe? featuredRecipe;
  final UserProfile profile;
}
