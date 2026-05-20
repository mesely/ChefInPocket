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

class IngredientPickerScreen extends StatefulWidget {
  const IngredientPickerScreen({super.key});

  @override
  State<IngredientPickerScreen> createState() => _IngredientPickerScreenState();
}

class _IngredientPickerScreenState extends State<IngredientPickerScreen> {
  final Set<String> _selectedIds = {'eggs', 'tomato', 'onion'};
  bool _isMatching = false;

  void _toggleIngredient(IngredientOption item) {
    setState(() {
      if (_selectedIds.contains(item.id)) {
        _selectedIds.remove(item.id);
      } else {
        _selectedIds.add(item.id);
      }
    });
  }

  Future<void> _findRecipes() async {
    if (_selectedIds.isEmpty || _isMatching) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one ingredient first.')),
      );
      return;
    }

    setState(() {
      _isMatching = true;
    });

    try {
      final selected = _selectedIds.toList();
      var slugs = await ApiService.instance.matchIngredientSlugs(selected);

      if (slugs.isEmpty) {
        final directMatches = await ApiService.instance
            .searchRecipesByIngredients(selected);
        slugs = directMatches.map((recipe) => recipe.id).toList();
      }

      if (!mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.recipeResults,
        arguments: {
          'ingredients': selected,
          'slugs': slugs,
          'cuisine': ModalRoute.of(context)?.settings.arguments as String?,
        },
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isMatching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuisine = ModalRoute.of(context)?.settings.arguments as String?;
    final dataProvider = context.watch<AppDataProvider>();

    return ChefPage(
      child: Builder(
        builder: (context) {
          if (dataProvider.isLoading && dataProvider.ingredients.isEmpty) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (dataProvider.errorMessage != null &&
              dataProvider.ingredients.isEmpty) {
            return Column(
              children: [
                Text(
                  'Ingredients could not be loaded.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.read<AppDataProvider>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            );
          }

          final ingredients = dataProvider.ingredients;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'What ingredients do you have?',
                style: AppTextStyles.display,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                cuisine == null
                    ? 'Tap what is already in your kitchen to match recipes faster.'
                    : 'Matching $cuisine ideas with your pantry.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${_selectedIds.length} ingredients selected',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final count = constraints.maxWidth > 420 ? 4 : 2;

                  return GridView.builder(
                    itemCount: ingredients.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.08,
                    ),
                    itemBuilder: (context, index) {
                      final item = ingredients[index];
                      final isSelected = _selectedIds.contains(item.id);

                      return GestureDetector(
                        onTap: () => _toggleIngredient(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySoft
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _isMatching ? null : _findRecipes,
                child: Text(_isMatching ? 'Finding...' : 'Find Recipes'),
              ),
            ],
          );
        },
      ),
    );
  }
}
