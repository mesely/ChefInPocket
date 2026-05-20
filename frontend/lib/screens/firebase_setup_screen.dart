import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.cloud_off_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Firebase setup is missing',
                      style: AppTextStyles.display,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Step 4 code is ready, but this device still needs real Firebase project files before the app can connect.',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Required files', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '1. ios/Runner/GoogleService-Info.plist\n2. android/app/google-services.json\n3. Optional: firebase_options.dart if you use FlutterFire CLI',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Initialization error', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(errorMessage, style: AppTextStyles.caption),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
