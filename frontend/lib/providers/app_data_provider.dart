import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../utils/recipe_filter.dart';

class AppDataProvider extends ChangeNotifier {
  AppDataProvider() {
    _initialize();
  }

  AppContent? _content;
  List<IngredientOption> _ingredients = const [];
  List<Recipe> _recipes = const [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<Recipe>>? _recipesSubscription;

  AppContent? get content => _content;
  List<IngredientOption> get ingredients => _ingredients;
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _initialize() async {
    try {
      _content = await ApiService.instance.fetchContent();
      _ingredients = await ApiService.instance.fetchIngredients();
      _bindRecipeStream();
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _bindRecipeStream() {
    _recipesSubscription?.cancel();
    _recipesSubscription = ApiService.instance.watchRecipes().listen(
      (items) {
        _recipes = items;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      _content = await ApiService.instance.fetchContent();
      _ingredients = await ApiService.instance.fetchIngredients();
      _bindRecipeStream();
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Recipe> searchRecipes(String query) {
    return RecipeFilter.searchRecipes(recipes: _recipes, query: query);
  }

  List<Recipe> recipesForCuisine(String cuisine) {
    return RecipeFilter.filterByCuisine(recipes: _recipes, cuisine: cuisine);
  }

  @override
  void dispose() {
    _recipesSubscription?.cancel();
    super.dispose();
  }
}
