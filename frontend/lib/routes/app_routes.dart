/// This class contains all the route names used in the app.
/// Using named routes makes navigation easier to manage.
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Authentication routes
  static const onboarding = '/';
  static const register = '/register';
  static const login = '/login';

  // Main app routes
  static const home = '/home';
  static const browseCuisine = '/browse-cuisine';
  static const ingredientPicker = '/ingredient-picker';
  static const recipeResults = '/recipe-results';
  static const recipeDetail = '/recipe-detail';
  static const servingScale = '/serving-scale';
  static const aiChat = '/ai-chat';
  static const groceryList = '/grocery-list';
  static const addRecipe = '/add-recipe';
  static const customizeIngredients = '/customize-ingredients';
  static const cookingSteps = '/cooking-steps';
  static const community = '/community';
  static const profile = '/profile';
  static const userProfile = '/user-profile';
  static const savedRecipes = '/saved-recipes';
  static const myRecipes = '/my-recipes';
  static const askQA = '/ask-qa';
}
