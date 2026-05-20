import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<AuthProvider>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      showSuccessDialog(
        context: context,
        title: 'Welcome Back',
        message: 'Login succeeded and Firebase connection is active.',
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE3DDD3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4D8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Log In',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.register,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Register',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Welcome back', style: AppTextStyles.display),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Use your Firebase account to open your synced recipes, saves, and grocery list.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EMAIL', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }

                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text('PASSWORD', style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }

                    if (value.length < 6) {
                      return 'Use at least 6 characters';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: Text(_isSubmitting ? 'Logging in...' : 'Log In'),
          ),
        ],
      ),
    );
  }
}
