import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class AskQAScreen extends StatefulWidget {
  const AskQAScreen({super.key});

  @override
  State<AskQAScreen> createState() => _AskQAScreenState();
}

class _AskQAScreenState extends State<AskQAScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _authorController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _questionController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await ApiService.instance.createCommunityPost(
        author: _authorController.text.trim().isEmpty
            ? '@me'
            : '@${_authorController.text.trim().toLowerCase().replaceAll(' ', '')}',
        title: _questionController.text.trim(),
        description: 'Community Q&A — feel free to reply.',
        recipeSlug: '',
        role: 'Q&A',
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
      );

      if (!mounted) return;

      showSuccessDialog(
        context: context,
        title: 'Question Posted',
        message: 'Your question is live in the community feed.',
        onPressed: () {
          Navigator.pushReplacementNamed(context, AppRoutes.community);
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
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppBackButton(),
          const SizedBox(height: AppSpacing.sm),
          Text('Ask the Community', style: AppTextStyles.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Post a cooking question and get answers from fellow chefs.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ask about substitutions, timing, techniques, or anything food-related.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR QUESTION', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _questionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'e.g. What can I substitute for tahini? How long should I marinate chicken?',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write your question';
                    }
                    if (value.trim().length < 10) {
                      return 'Please be more specific';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text('YOUR NAME (optional)', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Nilsu',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _isPosting ? null : _submit,
            child: Text(_isPosting ? 'Posting...' : 'Post Question'),
          ),
        ],
      ),
    );
  }
}
