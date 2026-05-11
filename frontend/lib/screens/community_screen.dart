import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firestore_models.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _searchController = TextEditingController();
  String _activeFilter = 'All';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecipeDoc> _filter(List<RecipeDoc> all) {
    final q = _query.trim().toLowerCase();
    return all.where((r) {
      final matchesCuisine = _activeFilter == 'All' ||
          r.cuisine.toLowerCase().contains(_activeFilter.toLowerCase());
      final matchesQuery = q.isEmpty ||
          '${r.createdByName} ${r.title} ${r.description}'
              .toLowerCase()
              .contains(q);
      return matchesCuisine && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Turkish', 'Italian', 'Mexican', 'Asian'];

    return ChefPage(
      currentRoute: AppRoutes.community,
      showBottomNav: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkButton,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addRecipe),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: StreamBuilder<List<RecipeDoc>>(
        stream: FirestoreService.instance.streamAllRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Column(
              children: [
                Text('Community feed could not be loaded.',
                    style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            );
          }

          final posts = _filter(snapshot.data ?? []);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ChefInPocket Community', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.xs),
              Text('Watch, share, and cook better.',
                  style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.md),
              AppSearchField(
                hint: 'Search creators, recipes...',
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filters.map((f) {
                  return InfoChip(
                    label: f,
                    isActive: f == _activeFilter,
                    onTap: () => setState(() => _activeFilter = f),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
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
                      Text(
                        'What did you cook today?',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Share a recipe or ask the community.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.addRecipe),
                              child: const Text('Post Recipe'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.askQA),
                              child: const Text('Ask Q&A'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (posts.isEmpty)
                Text('No recipes shared yet. Be the first!',
                    style: AppTextStyles.body)
              else
                ...posts.map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RecipePostCard(recipe: recipe),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RecipePostCard extends StatefulWidget {
  const _RecipePostCard({required this.recipe});

  final RecipeDoc recipe;

  @override
  State<_RecipePostCard> createState() => _RecipePostCardState();
}

class _RecipePostCardState extends State<_RecipePostCard> {
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    FirestoreService.instance
        .isRecipeSaved(widget.recipe.id)
        .then((saved) {
      if (mounted) setState(() => _isSaved = saved);
    });
  }

  Future<void> _toggleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      if (_isSaved) {
        await FirestoreService.instance.unsaveRecipe(widget.recipe.id);
      } else {
        await FirestoreService.instance.saveRecipe(SavedRecipeDoc(
          recipeId: widget.recipe.id,
          title: widget.recipe.title,
          subtitle: widget.recipe.cuisine,
          description: widget.recipe.description,
          imageUrl: widget.recipe.imageUrl,
          author: widget.recipe.createdByName,
          role: 'Recipe',
          createdBy: widget.recipe.createdBy,
          createdAt: widget.recipe.createdAt,
        ));
      }
      if (mounted) setState(() => _isSaved = !_isSaved);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update saved recipes.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openDetail(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.recipeDetail,
        arguments: widget.recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    final authorHandle = '@${widget.recipe.createdByName.replaceAll(' ', '').toLowerCase()}';
    final initial = widget.recipe.createdByName.isNotEmpty
        ? widget.recipe.createdByName[0].toUpperCase()
        : 'C';
    final uid = context.read<AuthProvider>().user?.uid;
    final isOwner = widget.recipe.createdBy == uid;

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
                  child: Text(initial),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.createdByName,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(authorHandle, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.danger,
                    onPressed: () async {
                      await FirestoreService.instance
                          .deleteRecipe(widget.recipe.id);
                    },
                  ),
                IconButton(
                  onPressed: _toggleSave,
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => _openDetail(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.recipe.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.recipe.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, err, stack) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => _openDetail(context),
              child: Text(widget.recipe.title, style: AppTextStyles.title),
            ),
            if (widget.recipe.cuisine.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(widget.recipe.cuisine, style: AppTextStyles.caption),
            ],
            if (widget.recipe.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(widget.recipe.description, style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.warmAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.restaurant_menu, size: 48, color: AppColors.textMuted),
    );
  }
}
