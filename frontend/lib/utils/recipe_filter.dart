import '../models/app_models.dart';

/// Pure helper methods for recipe filtering and searching.
/// Keeping this logic separate makes it easy to test and reuse.
class RecipeFilter {
  RecipeFilter._();

  /// Returns recipes that contain every selected ingredient.
  static List<Recipe> filterByAvailableIngredients({
    required List<Recipe> recipes,
    required List<String> availableIngredients,
  }) {
    final normalizedIngredients = availableIngredients
        .map(_normalize)
        .where((item) => item.isNotEmpty)
        .toSet();

    if (normalizedIngredients.isEmpty) {
      return recipes;
    }

    return recipes.where((recipe) {
      final recipeIngredients = recipe.ingredients
          .map((ingredient) => _normalize(ingredient.name))
          .toSet();

      return normalizedIngredients.every(recipeIngredients.contains);
    }).toList();
  }

  /// Returns recipes matching a search query in title, subtitle, or tags.
  static List<Recipe> searchRecipes({
    required List<Recipe> recipes,
    required String query,
  }) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return recipes;
    }

    return recipes.where((recipe) {
      return _matchesTagOrText(recipe, normalizedQuery);
    }).toList();
  }

  /// Returns recipes matching the selected cuisine label.
  static List<Recipe> filterByCuisine({
    required List<Recipe> recipes,
    required String cuisine,
  }) {
    final normalizedCuisine = _normalize(cuisine);
    if (normalizedCuisine.isEmpty || normalizedCuisine == 'other') {
      return recipes;
    }

    return recipes.where((recipe) {
      return _matchesTagOrText(recipe, normalizedCuisine);
    }).toList();
  }

  static bool _matchesTagOrText(Recipe recipe, String normalizedQuery) {
    final normalizedTags = recipe.tags.map(_normalize).toSet();
    if (normalizedTags.contains(normalizedQuery)) {
      return true;
    }

    final titleMatch = _normalize(recipe.title).contains(normalizedQuery);
    final subtitleMatch = _normalize(recipe.subtitle).contains(normalizedQuery);
    return titleMatch || subtitleMatch;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
