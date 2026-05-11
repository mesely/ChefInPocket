import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/preferences_provider.dart';
import 'routes/app_routes.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/ask_qa_screen.dart';
import 'screens/browse_cuisine_screen.dart';
import 'screens/community_screen.dart';
import 'screens/cooking_steps_screen.dart';
import 'screens/customize_ingredients_screen.dart';
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

class ChefInPocketApp extends StatelessWidget {
  const ChefInPocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChefInPocket',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: prefs.themeMode,
      initialRoute: AppRoutes.appEntry,
      routes: {
        AppRoutes.appEntry: (context) => const _AuthGate(),
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
        AppRoutes.aiChat: (context) => const AuthGuard(child: AiChatScreen()),
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
        AppRoutes.profile: (context) => const AuthGuard(child: ProfileScreen()),
        AppRoutes.userProfile: (context) =>
            const AuthGuard(child: UserProfileScreen()),
        AppRoutes.savedRecipes: (context) =>
            const AuthGuard(child: SavedRecipesScreen()),
        AppRoutes.myRecipes: (context) =>
            const AuthGuard(child: MyRecipesScreen()),
        AppRoutes.askQA: (context) => const AuthGuard(child: AskQAScreen()),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.unknown) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.isLoggedIn) {
      return const HomeScreen();
    }

    return const OnboardingScreen();
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.unknown) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isLoggedIn) {
      return const OnboardingScreen();
    }

    return child;
  }
}
