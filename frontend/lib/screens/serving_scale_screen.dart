import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class ServingScaleScreen extends StatefulWidget {
  const ServingScaleScreen({super.key});

  @override
  State<ServingScaleScreen> createState() => _ServingScaleScreenState();
}

class _ServingScaleScreenState extends State<ServingScaleScreen> {
  late Future<_ScaleData> _scaleDataFuture;
  bool _didLoad = false;
  bool _initializedServings = false;
  int _servings = 2;
  Recipe? _recipe;

  String get _slug {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is String && arguments.isNotEmpty ? arguments : 'menemen';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _scaleDataFuture = _loadScaleData();
      _didLoad = true;
    }
  }

  Future<_ScaleData> _loadScaleData() async {
    final recipe = _recipe ?? await ApiService.instance.fetchRecipe(_slug);
    _recipe = recipe;

    if (!_initializedServings) {
      _servings = recipe.servings;
      _initializedServings = true;
    }

    final scaledIngredients =
        await ApiService.instance.scaleRecipe(recipe.id, _servings);

    return _ScaleData(recipe: recipe, ingredients: scaledIngredients);
  }

  void _changeServings(int delta) {
    final nextServings = _servings + delta;
    if (nextServings < 1) {
      return;
    }

    setState(() {
      _servings = nextServings;
      _scaleDataFuture = _loadScaleData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: FutureBuilder<_ScaleData>(
        future: _scaleDataFuture,
        builder: (context, snapshot) {
          final ingredients = snapshot.data?.ingredients ?? const <ScaledIngredient>[];
          final recipe = snapshot.data?.recipe ?? _recipe;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppSpacing.sm),
              Text('Adjust Servings', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              Text(
                recipe == null
                    ? 'Adjust the number of servings below.'
                    : 'Scaling ingredients for ${recipe.title}.',
                style: AppTextStyles.subtitle,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: _servings <= 1 ? null : () => _changeServings(-1),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('-'),
                      ),
                      Column(
                        children: [
                          Text('$_servings', style: AppTextStyles.display),
                          Text('servings', style: AppTextStyles.caption),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () => _changeServings(1),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('+'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppSectionHeader(label: 'Scaled Ingredients'),
              const SizedBox(height: AppSpacing.sm),
              if (snapshot.connectionState == ConnectionState.waiting && ingredients.isEmpty)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text('Could not scale this recipe.', style: AppTextStyles.body)
              else
                ...ingredients.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ListTile(
                        title: Text(
                          item.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: Text(
                          item.label,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: recipe == null
                    ? null
                    : () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.recipeDetail,
                          arguments: recipe.id,
                        );
                      },
                child: const Text('Save & Continue'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScaleData {
  const _ScaleData({
    required this.recipe,
    required this.ingredients,
  });

  final Recipe recipe;
  final List<ScaledIngredient> ingredients;
}
