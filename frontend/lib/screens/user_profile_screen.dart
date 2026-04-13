import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<List<Recipe>> _recipesFuture;
  bool _didLoad = false;

  String get _username {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is String && arguments.isNotEmpty ? arguments : '@user';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _recipesFuture = _loadRecipes();
      _didLoad = true;
    }
  }

  Future<List<Recipe>> _loadRecipes() async {
    final posts = await ApiService.instance.fetchCommunityPosts();
    final recipeSlugs = posts
        .where((post) => post.author == _username && post.recipeSlug != null)
        .map((post) => post.recipeSlug!)
        .toList();

    return ApiService.instance.fetchRecipesBySlugs(recipeSlugs);
  }

  @override
  Widget build(BuildContext context) {
    final bareName = _username.replaceFirst('@', '');
    final displayName = bareName.isEmpty
        ? 'User'
        : bareName.characters.first.toUpperCase() + bareName.substring(1);

    return ChefPage(
      child: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          final recipes = snapshot.data ?? const <Recipe>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          _username.substring(1, 2).toUpperCase(),
                          style: AppTextStyles.display,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(displayName, style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    Text(_username, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: _CompactMetric(
                  value: '${recipes.length}',
                  label: 'recipes shared',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppSectionHeader(label: 'Recipes'),
              const SizedBox(height: AppSpacing.sm),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text('User recipes could not be loaded.', style: AppTextStyles.body)
              else if (recipes.isEmpty)
                Text('This chef has not shared a recipe yet.', style: AppTextStyles.body)
              else
                ...recipes.map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecipeCard(recipe: recipe),
                  ),
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

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.recipeDetail,
            arguments: recipe.id,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      color: AppColors.background,
                      child: const Icon(Icons.restaurant),
                    );
                  },
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
                    const SizedBox(height: 4),
                    Text(recipe.subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
