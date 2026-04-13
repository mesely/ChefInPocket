import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class CookingStepsScreen extends StatefulWidget {
  const CookingStepsScreen({super.key});

  @override
  State<CookingStepsScreen> createState() => _CookingStepsScreenState();
}

class _CookingStepsScreenState extends State<CookingStepsScreen> {
  late Future<Recipe> _recipeFuture;
  bool _didLoad = false;

  String get _slug {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is String && arguments.isNotEmpty ? arguments : 'menemen';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _recipeFuture = ApiService.instance.fetchRecipe(_slug);
      _didLoad = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Text('Cooking steps could not be loaded.', style: AppTextStyles.body);
          }

          final recipe = snapshot.data!;
          final steps = recipe.steps.isEmpty
              ? ['Prepare your ingredients and follow the recipe description.']
              : recipe.steps;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(recipe.title, style: AppTextStyles.display),
                  ),
                  InfoChip(
                    label: '${steps.length} steps',
                    isActive: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Follow each step carefully for the best result.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...steps.asMap().entries.map((entry) {
                final stepNum = entry.key + 1;
                final step = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$stepNum',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(step, style: AppTextStyles.body),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  showSuccessDialog(
                    context: context,
                    title: 'Recipe Complete',
                    message: 'Nice work. Your cooking session is done.',
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                  );
                },
                child: const Text('Mark as Done'),
              ),
            ],
          );
        },
      ),
    );
  }
}
