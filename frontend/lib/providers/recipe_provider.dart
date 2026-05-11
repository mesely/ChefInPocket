import 'package:flutter/material.dart';

import '../models/firestore_models.dart';
import '../services/firestore_service.dart';

class RecipeProvider extends ChangeNotifier {
  final List<RecipeDoc> _myRecipes = [];
  final List<RecipeDoc> _allRecipes = [];
  bool _loading = false;
  String? _error;

  List<RecipeDoc> get myRecipes => _myRecipes;
  List<RecipeDoc> get allRecipes => _allRecipes;
  bool get loading => _loading;
  String? get error => _error;

  Stream<List<RecipeDoc>> get myRecipesStream =>
      FirestoreService.instance.streamMyRecipes();

  Stream<List<RecipeDoc>> get allRecipesStream =>
      FirestoreService.instance.streamAllRecipes();

  Future<RecipeDoc?> createRecipe({
    required String title,
    required String description,
    required String cuisine,
    required String duration,
    required int servings,
    required List<String> steps,
    required List<Map<String, dynamic>> ingredients,
    required List<String> tags,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final recipe = await FirestoreService.instance.createRecipe(
        title: title,
        description: description,
        cuisine: cuisine,
        duration: duration,
        servings: servings,
        steps: steps,
        ingredients: ingredients,
        tags: tags,
      );
      return recipe;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    await FirestoreService.instance.deleteRecipe(recipeId);
  }
}
