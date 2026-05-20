import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bootstrap/firebase_bootstrap.dart';
import 'providers/app_data_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/preferences_provider.dart';
import 'routes/app_routes.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/app_entry_screen.dart';
import 'screens/ask_qa_screen.dart';
import 'screens/browse_cuisine_screen.dart';
import 'screens/community_screen.dart';
import 'screens/cooking_steps_screen.dart';
import 'screens/customize_ingredients_screen.dart';
import 'screens/firebase_setup_screen.dart';
import 'screens/grocery_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ingredient_picker_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_recipes_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/recipe_results_screen.dart';
import 'screens/register_screen.dart';
import 'screens/saved_recipes_screen.dart';
import 'screens/serving_scale_screen.dart';
import 'screens/user_profile_screen.dart';
import 'theme/app_theme.dart';

/// Main application widget.
/// This configures Firebase-aware startup, providers, theme, and routes.
class ChefInPocketApp extends StatelessWidget {
  const ChefInPocketApp({super.key, required this.bootstrapResult});

  final FirebaseBootstrapResult bootstrapResult;

  @override
  Widget build(BuildContext context) {
    if (!bootstrapResult.isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChefInPocket',
        theme: AppTheme.lightTheme,
        home: FirebaseSetupScreen(
          errorMessage:
              bootstrapResult.errorMessage ?? 'Unknown Firebase error.',
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, preferencesProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ChefInPocket',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: preferencesProvider.themeMode,
            initialRoute: AppRoutes.appEntry,
            routes: {
              AppRoutes.appEntry: (context) => const AppEntryScreen(),
              AppRoutes.onboarding: (context) => const OnboardingScreen(),
              AppRoutes.register: (context) => const RegisterScreen(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.home: (context) => const AuthGuard(child: HomeScreen()),
              AppRoutes.browseCuisine: (context) =>
                  const AuthGuard(child: BrowseCuisineScreen()),
              AppRoutes.ingredientPicker: (context) =>
                  const AuthGuard(child: IngredientPickerScreen()),
              AppRoutes.recipeResults: (context) =>
                  const AuthGuard(child: RecipeResultsScreen()),
              AppRoutes.recipeDetail: (context) =>
                  const AuthGuard(child: RecipeDetailScreen()),
              AppRoutes.servingScale: (context) =>
                  const AuthGuard(child: ServingScaleScreen()),
              AppRoutes.aiChat: (context) =>
                  const AuthGuard(child: AiChatScreen()),
              AppRoutes.groceryList: (context) =>
                  const AuthGuard(child: GroceryListScreen()),
              AppRoutes.addRecipe: (context) =>
                  const AuthGuard(child: AddRecipeScreen()),
              AppRoutes.customizeIngredients: (context) =>
                  const AuthGuard(child: CustomizeIngredientsScreen()),
              AppRoutes.cookingSteps: (context) =>
                  const AuthGuard(child: CookingStepsScreen()),
              AppRoutes.community: (context) =>
                  const AuthGuard(child: CommunityScreen()),
              AppRoutes.profile: (context) =>
                  const AuthGuard(child: ProfileScreen()),
              AppRoutes.userProfile: (context) =>
                  const AuthGuard(child: UserProfileScreen()),
              AppRoutes.savedRecipes: (context) =>
                  const AuthGuard(child: SavedRecipesScreen()),
              AppRoutes.myRecipes: (context) =>
                  const AuthGuard(child: MyRecipesScreen()),
              AppRoutes.askQA: (context) =>
                  const AuthGuard(child: AskQAScreen()),
            },
          );
        },
      ),
    );
  }
}
