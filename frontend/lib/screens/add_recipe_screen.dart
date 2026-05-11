import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipe_provider.dart';
import '../routes/app_routes.dart';
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
  final _descController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  String _selectedCuisine = 'Turkish';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RecipeProvider>();

    final rawIngredients = _ingredientsController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => {'name': l, 'amountPerServing': 1.0, 'unit': ''})
        .toList();

    final steps = _stepsController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final recipe = await provider.createRecipe(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      cuisine: _selectedCuisine,
      duration: '${_prepTimeController.text.trim()} min',
      servings: int.tryParse(_servingsController.text.trim()) ?? 2,
      steps: steps.isEmpty ? ['Prepare and cook as described.'] : steps,
      ingredients: rawIngredients,
      tags: [_selectedCuisine],
    );

    if (!mounted) return;

    if (recipe != null) {
      showSuccessDialog(
        context: context,
        title: 'Recipe Published',
        message: 'Your recipe has been shared with the community.',
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.community, (_) => false);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Could not publish recipe.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const cuisines = ['Turkish', 'Italian', 'French', 'Mexican', 'Asian', 'Healthy', 'Other'];
    final isPublishing = context.watch<RecipeProvider>().loading;

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
                  decoration:
                      const InputDecoration(hintText: 'e.g. Creamy Menemen'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('DESCRIPTION', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      hintText: 'A short description of your recipe...'),
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
                      onTap: () => setState(() => _selectedCuisine = cuisine),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('INGREDIENTS (one per line)',
                    style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _ingredientsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Eggs\nTomatoes\nOnion\nOlive oil',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingredients are required'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('STEPS (one per line)', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _stepsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Heat oil in pan\nAdd tomatoes\nCrack eggs...',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(hintText: 'Prep time (min)'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(hintText: 'Servings'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: isPublishing ? null : _submit,
            child: Text(isPublishing ? 'Publishing...' : 'Publish Recipe'),
          ),
        ],
      ),
    );
  }
}
