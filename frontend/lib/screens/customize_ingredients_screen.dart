import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class CustomizeIngredientsScreen extends StatefulWidget {
  const CustomizeIngredientsScreen({super.key});

  @override
  State<CustomizeIngredientsScreen> createState() =>
      _CustomizeIngredientsScreenState();
}

class _CustomizeIngredientsScreenState
    extends State<CustomizeIngredientsScreen> {
  late Future<AppContent> _contentFuture;
  bool _didLoad = false;
  bool _isApplying = false;
  final Set<String> _selectedIngredients = {};

  String get _slug {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is String && arguments.isNotEmpty ? arguments : 'menemen';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _contentFuture = ApiService.instance.fetchContent();
      _didLoad = true;
    }
  }

  Future<void> _applyChanges() async {
    if (_isApplying) {
      return;
    }

    setState(() {
      _isApplying = true;
    });

    try {
      await ApiService.instance.customizeRecipe(
        _slug,
        _selectedIngredients.toList(),
      );

      if (!mounted) {
        return;
      }

      showSuccessDialog(
        context: context,
        title: 'Changes Applied',
        message: 'Your ingredient choices were saved for this recipe preview.',
        onPressed: () {
          Navigator.pop(context);
        },
      );
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
          _isApplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: FutureBuilder<AppContent>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Text('Customization options could not be loaded.', style: AppTextStyles.body);
          }

          final options = snapshot.data!.customizationOptions;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppSpacing.sm),
              Text('Customize Ingredients', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose the swaps you want to apply while keeping the recipe balanced.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: CheckboxListTile(
                      value: _selectedIngredients.contains(option.ingredient),
                      activeColor: AppColors.primary,
                      title: Text(
                        option.ingredient,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(option.suggestion, style: AppTextStyles.caption),
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (_) {
                        setState(() {
                          if (_selectedIngredients.contains(option.ingredient)) {
                            _selectedIngredients.remove(option.ingredient);
                          } else {
                            _selectedIngredients.add(option.ingredient);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: _isApplying ? null : _applyChanges,
                child: Text(_isApplying ? 'Applying...' : 'Apply Changes'),
              ),
            ],
          );
        },
      ),
    );
  }
}
