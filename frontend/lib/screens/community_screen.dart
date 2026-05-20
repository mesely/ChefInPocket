import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
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

  List<CommunityPost> _visiblePosts(List<CommunityPost> posts) {
    final query = _query.trim().toLowerCase();

    return posts.where((post) {
      final roleMatches =
          _activeFilter == 'All' ||
          post.role.toLowerCase().contains(_activeFilter.toLowerCase());
      final queryMatches =
          query.isEmpty ||
          '${post.author} ${post.title} ${post.description}'
              .toLowerCase()
              .contains(query);

      return roleMatches && queryMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Recipe', 'Q&A'];

    return ChefPage(
      currentRoute: AppRoutes.community,
      showBottomNav: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkButton,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addRecipe),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: StreamBuilder<List<CommunityPost>>(
        stream: ApiService.instance.watchCommunityPosts(),
        builder: (context, postsSnapshot) {
          if (postsSnapshot.connectionState == ConnectionState.waiting &&
              !postsSnapshot.hasData) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (postsSnapshot.hasError) {
            return Text(
              'Community feed could not be loaded.',
              style: AppTextStyles.body,
            );
          }

          final posts = _visiblePosts(postsSnapshot.data ?? const []);

          return StreamBuilder<List<SavedRecipe>>(
            stream: ApiService.instance.watchSavedRecipes(),
            builder: (context, savedSnapshot) {
              final savedSlugs = (savedSnapshot.data ?? const <SavedRecipe>[])
                  .map((item) => item.recipeSlug)
                  .toSet();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ChefInPocket Community', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Watch, share, and cook better.',
                    style: AppTextStyles.display,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppSearchField(
                    hint: 'Search creators, recipes, techniques...',
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filters.map((filter) {
                      return InfoChip(
                        label: filter,
                        isActive: filter == _activeFilter,
                        onTap: () {
                          setState(() {
                            _activeFilter = filter;
                          });
                        },
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
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Share a recipe or ask the community a cooking question.',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.addRecipe,
                                    );
                                  },
                                  child: const Text('Post Recipe'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.askQA,
                                    );
                                  },
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
                    Text(
                      'No posts match this filter yet.',
                      style: AppTextStyles.body,
                    )
                  else
                    ...posts.map(
                      (post) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CommunityPostCard(
                          post: post,
                          isSaved:
                              post.recipeSlug != null &&
                              savedSlugs.contains(post.recipeSlug),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.post, required this.isSaved});

  final CommunityPost post;
  final bool isSaved;

  Future<void> _toggleSaved(BuildContext context) async {
    final recipeSlug = post.recipeSlug;
    if (recipeSlug == null) {
      return;
    }

    try {
      if (isSaved) {
        await ApiService.instance.removeSavedRecipe(recipeSlug);
      } else {
        await ApiService.instance.saveRecipe(SavedRecipe.fromPost(post));
      }
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _openRecipe(BuildContext context) {
    final recipeSlug = post.recipeSlug;
    if (recipeSlug == null) {
      return;
    }

    Navigator.pushNamed(context, AppRoutes.recipeDetail, arguments: recipeSlug);
  }

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
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.userProfile,
                      arguments: post.author,
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Text(post.author.substring(1, 2).toUpperCase()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.userProfile,
                        arguments: post.author,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(post.role, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
                if (post.recipeSlug != null)
                  IconButton(
                    onPressed: () => _toggleSaved(context),
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => _openRecipe(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  post.imageUrl,
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
              onTap: () => _openRecipe(context),
              child: Text(post.title, style: AppTextStyles.title),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(post.description, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
