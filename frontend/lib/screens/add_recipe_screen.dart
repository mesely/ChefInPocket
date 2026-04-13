import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  String _selectedCuisine = 'Turkish';
  bool _isPublishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isPublishing) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      final recipe = await ApiService.instance.createRecipe(
        title: _titleController.text.trim(),
        ingredients: _ingredientsController.text.trim(),
        cuisine: _selectedCuisine,
        prepTime: _prepTimeController.text.trim(),
        servings: _servingsController.text.trim(),
      );

      await ApiService.instance.createCommunityPost(
        author: '@me',
        title: recipe.title,
        description: recipe.description,
        recipeSlug: recipe.id,
        imageUrl: recipe.imageUrl,
      );

      if (!mounted) return;

      showSuccessDialog(
        context: context,
        title: 'Recipe Published',
        message: 'Your recipe has been shared with the community.',
        onPressed: () {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.recipeDetail,
            arguments: recipe.id,
          );
        },
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const cuisines = ['Turkish', 'Italian', 'French', 'Healthy', 'Athlete', 'Other'];

    return ChefPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppBackButton(),
          const SizedBox(height: AppSpacing.sm),
          Text('Post a Recipe', style: AppTextStyles.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Share a dish you love with the community.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RECIPE TITLE', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'e.g. Creamy Menemen'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text('CUISINE', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cuisines.map((cuisine) {
                    return InfoChip(
                      label: cuisine,
                      isActive: _selectedCuisine == cuisine,
                      onTap: () {
                        setState(() {
                          _selectedCuisine = cuisine;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('INGREDIENTS', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _ingredientsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Eggs, tomatoes, onion, olive oil...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingredients are required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Prep time (min)'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Servings'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _isPublishing ? null : _submit,
            child: Text(_isPublishing ? 'Publishing...' : 'Publish Recipe'),
          ),
        ],
      ),
    );
  }
}
