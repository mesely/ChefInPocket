import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_models.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const _baseUrl = 'https://mesely-chefinpocket.hf.space';

  /// Email of the currently logged-in user, stored after login/register.
  static String? loggedInEmail;

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('$_baseUrl$path').replace(queryParameters: queryParameters);
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
      };

  Future<dynamic> _decode(http.Response response) async {
    final body = response.body.trim();
    final data = body.isEmpty ? null : jsonDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data is Map && data['message'] != null
        ? data['message'].toString()
        : 'Request failed with ${response.statusCode}.';
    throw ApiException(message);
  }

  Future<dynamic> _get(String path, {Map<String, String>? query}) async {
    return _decode(await http.get(_uri(path, query)));
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    return _decode(
      await http.post(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> _delete(String path) async {
    return _decode(await http.delete(_uri(path)));
  }

  Future<AppContent> fetchContent() async {
    final data = await _get('/api/content/bootstrap');
    return AppContent.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<Recipe>> fetchRecipes() async {
    final data = await _get('/api/recipes');
    return (data as List)
        .map((item) => Recipe.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Recipe> fetchFeaturedRecipe() async {
    final data = await _get('/api/recipes/featured');
    return Recipe.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Recipe> fetchRecipe(String slug) async {
    final data = await _get('/api/recipes/$slug');
    return Recipe.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Recipe?> fetchRecipeOrNull(String slug) async {
    try {
      return fetchRecipe(slug);
    } on ApiException {
      return null;
    }
  }

  Future<List<Recipe>> fetchRecipesBySlugs(List<String> slugs) async {
    if (slugs.isEmpty) {
      return fetchRecipes();
    }

    final recipes = await Future.wait(slugs.map(fetchRecipeOrNull));
    return recipes.whereType<Recipe>().toList();
  }

  Future<List<Recipe>> searchRecipesByIngredients(List<String> ingredients) async {
    final data = await _post('/api/recipes/search-by-ingredients', {
      'ingredients': ingredients,
    });

    final results = data is Map ? data['results'] as List? : null;
    if (results == null) {
      return const [];
    }

    return results
        .map((item) => Recipe.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ScaledIngredient>> scaleRecipe(String slug, int servings) async {
    final data = await _post('/api/recipes/$slug/scale', {
      'servings': servings,
    });

    final items = data is Map ? data['scaledIngredients'] as List? : null;
    if (items == null) {
      return const [];
    }

    return items
        .map((item) => ScaledIngredient.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<String> customizeRecipe(
    String slug,
    List<String> replacements,
  ) async {
    final data = await _post('/api/recipes/$slug/customize', {
      'replacements': replacements,
    });

    return data is Map && data['message'] != null
        ? data['message'].toString()
        : 'Customization applied.';
  }

  Future<Recipe> createRecipe({
    required String title,
    required String ingredients,
    required String cuisine,
    required String prepTime,
    required String servings,
  }) async {
    final data = await _post('/api/recipes', {
      'title': title,
      'ingredients': ingredients,
      'cuisine': cuisine,
      'prepTime': prepTime,
      'servings': servings,
    });

    return Recipe.fromJson(Map<String, dynamic>.from(data['recipe']));
  }

  Future<List<IngredientOption>> fetchIngredients() async {
    final data = await _get('/api/pantry/ingredients');
    return (data as List)
        .map((item) => IngredientOption.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<String>> matchIngredientSlugs(List<String> ingredients) async {
    final data = await _post('/api/pantry/match', {
      'ingredients': ingredients,
    });

    final slugs = data is Map ? data['recommendedRecipeSlugs'] as List? : null;
    if (slugs == null) {
      return const [];
    }

    return slugs.map((item) => item.toString()).toList();
  }

  Future<List<GroceryItem>> fetchGroceryList() async {
    final data = await _get('/api/pantry/grocery-list');
    return (data as List)
        .map((item) => GroceryItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<GroceryItem> addGroceryItem(String title) async {
    final data = await _post('/api/pantry/grocery-list', {
      'title': title,
    });

    return GroceryItem.fromJson(Map<String, dynamic>.from(data['item']));
  }

  Future<void> removeGroceryItem(String id) async {
    await _delete('/api/pantry/grocery-list/$id');
  }

  Future<List<CommunityPost>> fetchCommunityPosts() async {
    final data = await _get('/api/community/posts');
    return (data as List)
        .map((item) => CommunityPost.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<CommunityPost> createCommunityPost({
    required String author,
    required String title,
    required String description,
    required String recipeSlug,
    String role = 'Recipe',
    String? imageUrl,
  }) async {
    final data = await _post('/api/community/posts', {
      'author': author,
      'title': title,
      'description': description,
      'role': role,
      'recipeSlug': recipeSlug,
      'imageUrl': imageUrl,
    });

    return CommunityPost.fromJson(Map<String, dynamic>.from(data['post']));
  }

  Future<List<SavedRecipe>> fetchSavedRecipes() async {
    final data = await _get('/api/content/saved-recipes');
    return (data as List)
        .map((item) => SavedRecipe.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<SavedRecipe> saveRecipe(SavedRecipe recipe) async {
    final data = await _post('/api/content/saved-recipes', recipe.toJson());
    return SavedRecipe.fromJson(Map<String, dynamic>.from(data['savedRecipe']));
  }

  Future<void> removeSavedRecipe(String recipeSlug) async {
    await _delete('/api/content/saved-recipes/$recipeSlug');
  }

  Future<UserProfile> fetchProfile() async {
    final query = loggedInEmail != null ? {'email': loggedInEmail!} : null;
    final data = await _get('/api/auth/profile', query: query);
    return UserProfile.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> login(String email, String password) async {
    await _post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    loggedInEmail = email.trim().toLowerCase();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _post('/api/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    loggedInEmail = email.trim().toLowerCase();
  }

  Future<List<ChatMessage>> fetchChatHistory(String context) async {
    final data = await _get('/api/assistant/history', query: {
      'context': context,
    });

    return (data as List)
        .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ChatMessage> sendAssistantMessage({
    required String context,
    required String message,
  }) async {
    final data = await _post('/api/assistant/message', {
      'context': context,
      'message': message,
    });

    return ChatMessage(
      text: data is Map && data['reply'] != null
          ? data['reply'].toString()
          : 'I saved that note for this recipe.',
      isChef: true,
    );
  }
}
