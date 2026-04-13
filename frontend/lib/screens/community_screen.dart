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
  late Future<_CommunityData> _communityFuture;
  final _searchController = TextEditingController();
  String _activeFilter = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _communityFuture = _loadCommunity();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<_CommunityData> _loadCommunity() async {
    final results = await Future.wait([
      ApiService.instance.fetchCommunityPosts(),
      ApiService.instance.fetchSavedRecipes(),
    ]);

    return _CommunityData(
      posts: results[0] as List<CommunityPost>,
      savedSlugs: (results[1] as List<SavedRecipe>)
          .map((item) => item.recipeSlug)
          .toSet(),
    );
  }

  List<CommunityPost> _visiblePosts(List<CommunityPost> posts) {
    final query = _query.trim().toLowerCase();

    return posts.where((post) {
      final roleMatches = _activeFilter == 'All' ||
          post.role.toLowerCase().contains(_activeFilter.toLowerCase());
      final queryMatches = query.isEmpty ||
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
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addRecipe);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: FutureBuilder<_CommunityData>(
        future: _communityFuture,
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
                Text('Community feed could not be loaded.', style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _communityFuture = _loadCommunity();
                  }),
                  child: const Text('Retry'),
                ),
              ],
            );
          }

          final data = snapshot.data!;
          final posts = _visiblePosts(data.posts);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ChefInPocket Community', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.xs),
              Text('Watch, share, and cook better.', style: AppTextStyles.display),
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
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Share what you cooked or ask a question.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.addRecipe);
                              },
                              child: const Text('Post Recipe'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.askQA);
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
                Text('No posts match this filter yet.', style: AppTextStyles.body)
              else
                ...posts.map(
                  (post) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CommunityPostCard(
                      post: post,
                      initiallySaved: post.recipeSlug != null &&
                          data.savedSlugs.contains(post.recipeSlug),
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

class _CommunityPostCard extends StatefulWidget {
  const _CommunityPostCard({
    required this.post,
    required this.initiallySaved,
  });

  final CommunityPost post;
  final bool initiallySaved;

  @override
  State<_CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<_CommunityPostCard> {
  late bool _isSaved;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initiallySaved;
  }

  Future<void> _toggleSaved() async {
    final recipeSlug = widget.post.recipeSlug;
    if (recipeSlug == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isSaved) {
        await ApiService.instance.removeSavedRecipe(recipeSlug);
      } else {
        await ApiService.instance.saveRecipe(SavedRecipe.fromPost(widget.post));
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaved = !_isSaved;
      });
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

  void _openRecipe(BuildContext context) {
    final recipeSlug = widget.post.recipeSlug;
    if (recipeSlug == null) {
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.recipeDetail,
      arguments: recipeSlug,
    );
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
                      arguments: widget.post.author,
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Text(widget.post.author.substring(1, 2).toUpperCase()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.userProfile,
                        arguments: widget.post.author,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.author,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(widget.post.role, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.post.recipeSlug == null ? null : _toggleSaved,
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? AppColors.primary : AppColors.textMuted,
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
                  widget.post.imageUrl,
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
              child: Text(widget.post.title, style: AppTextStyles.title),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.post.description, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _CommunityData {
  const _CommunityData({
    required this.posts,
    required this.savedSlugs,
  });

  final List<CommunityPost> posts;
  final Set<String> savedSlugs;
}
