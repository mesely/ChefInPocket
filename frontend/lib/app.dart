import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/ask_qa_screen.dart';
import 'screens/my_recipes_screen.dart';
import 'screens/browse_cuisine_screen.dart';
import 'screens/community_screen.dart';
import 'screens/cooking_steps_screen.dart';
import 'screens/customize_ingredients_screen.dart';
import 'screens/grocery_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ingredient_picker_screen.dart';
import 'screens/login_screen.dart';
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
/// This is where we configure the MaterialApp with our theme and routes.
class ChefInPocketApp extends StatelessWidget {
  const ChefInPocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChefInPocket',
      theme: AppTheme.lightTheme,
      // Set the initial route to onboarding screen
      initialRoute: AppRoutes.onboarding,
      // Define all named routes for navigation
      routes: {
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.browseCuisine: (context) => const BrowseCuisineScreen(),
        AppRoutes.ingredientPicker: (context) => const IngredientPickerScreen(),
        AppRoutes.recipeResults: (context) => const RecipeResultsScreen(),
        AppRoutes.recipeDetail: (context) => const RecipeDetailScreen(),
        AppRoutes.servingScale: (context) => const ServingScaleScreen(),
        AppRoutes.aiChat: (context) => const AiChatScreen(),
        AppRoutes.groceryList: (context) => const GroceryListScreen(),
        AppRoutes.addRecipe: (context) => const AddRecipeScreen(),
        AppRoutes.customizeIngredients: (context) =>
            const CustomizeIngredientsScreen(),
        AppRoutes.cookingSteps: (context) => const CookingStepsScreen(),
        AppRoutes.community: (context) => const CommunityScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.userProfile: (context) => const UserProfileScreen(),
        AppRoutes.savedRecipes: (context) => const SavedRecipesScreen(),
        AppRoutes.myRecipes: (context) => const MyRecipesScreen(),
        AppRoutes.askQA: (context) => const AskQAScreen(),
      },
    );
  }
}
