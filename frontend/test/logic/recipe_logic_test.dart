import 'package:chef_in_pocket_app/models/app_models.dart';
import 'package:chef_in_pocket_app/utils/recipe_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'RecipeFilter returns only recipes that match all selected ingredients',
    () {
      // This recipe set is intentionally small and explicit so the business
      // rule stays easy to read and maintain.
      final recipes = [
        _buildRecipe(
          id: 'feta-menemen',
          title: 'Feta Menemen',
          ingredients: ['Eggs', 'Tomatoes', 'Onion', 'Feta'],
        ),
        _buildRecipe(
          id: 'garden-pasta',
          title: 'Garden Pasta',
          ingredients: ['Pasta', 'Tomatoes', 'Garlic', 'Fresh Herbs'],
        ),
        _buildRecipe(
          id: 'power-bowl',
          title: 'Protein Power Bowl',
          ingredients: ['Chicken Breast', 'Rice', 'Spinach', 'Yogurt'],
        ),
      ];

      // The selected ingredients use mixed casing on purpose.
      // The filter should normalize values and still find the correct recipe.
      final filteredRecipes = RecipeFilter.filterByAvailableIngredients(
        recipes: recipes,
        availableIngredients: ['eggs', 'TOMATOES', 'feta'],
      );

      expect(filteredRecipes, hasLength(1));
      expect(filteredRecipes.single.id, 'feta-menemen');
      expect(filteredRecipes.single.title, 'Feta Menemen');
    },
  );

  test('RecipeFilter respects exact cuisine tags like Turkish', () {
    final recipes = [
      _buildRecipe(
        id: 'feta-menemen',
        title: 'Feta Menemen',
        ingredients: ['Eggs', 'Tomatoes', 'Onion', 'Feta'],
        tags: const ['Turkish', 'Quick'],
      ),
      _buildRecipe(
        id: 'garden-pasta',
        title: 'Garden Pasta',
        ingredients: ['Pasta', 'Tomatoes', 'Garlic', 'Fresh Herbs'],
        tags: const ['Italian', 'Easy'],
      ),
    ];

    final filteredRecipes = RecipeFilter.filterByCuisine(
      recipes: recipes,
      cuisine: 'Turkish',
    );

    expect(filteredRecipes, hasLength(1));
    expect(filteredRecipes.single.id, 'feta-menemen');
  });
}

Recipe _buildRecipe({
  required String id,
  required String title,
  required List<String> ingredients,
  List<String> tags = const ['Test'],
}) {
  return Recipe(
    id: id,
    title: title,
    subtitle: 'Test recipe',
    description: 'Used to validate recipe filtering logic.',
    duration: '20 min',
    servings: 2,
    tags: tags,
    ingredients: ingredients
        .map(
          (ingredient) => IngredientPortion(
            name: ingredient,
            amountPerServing: 1,
            unit: 'item',
          ),
        )
        .toList(),
    steps: const ['Cook and serve.'],
    imageUrl: '',
  );
}
