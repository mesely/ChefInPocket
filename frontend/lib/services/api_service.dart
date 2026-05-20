import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../utils/assistant_retrieval.dart';
import '../utils/recipe_filter.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();
  static const Duration _networkTimeout = Duration(seconds: 12);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void>? _seedFuture;
  String? _seedUserId;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _recipes =>
      _db.collection('recipes');
  CollectionReference<Map<String, dynamic>> get _communityPosts =>
      _db.collection('community_posts');
  CollectionReference<Map<String, dynamic>> get _savedRecipes =>
      _db.collection('saved_recipes');
  CollectionReference<Map<String, dynamic>> get _groceryItems =>
      _db.collection('grocery_items');
  CollectionReference<Map<String, dynamic>> get _assistantMessages =>
      _db.collection('assistant_messages');

  User? get currentUser => _auth.currentUser;
  String? get loggedInEmail => _auth.currentUser?.email;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> login(String email, String password) async {
    try {
      await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(_networkTimeout);
    } on FirebaseAuthException catch (error) {
      throw ApiException(_friendlyAuthMessage(error));
    } on TimeoutException {
      throw const ApiException(
        'Login is taking too long. Please check your connection and try again.',
      );
    } catch (_) {
      throw const ApiException(
        'Login failed. Please check your connection and try again.',
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String gender = 'prefer_not_to_say',
  }) async {
    try {
      final credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(_networkTimeout);
      await credential.user?.updateDisplayName(fullName.trim());
      await ensureCurrentUserProfile(fullName: fullName, gender: gender);
    } on FirebaseAuthException catch (error) {
      throw ApiException(_friendlyAuthMessage(error));
    } on TimeoutException {
      throw const ApiException(
        'Registration is taking too long. Please check your connection and try again.',
      );
    } catch (_) {
      throw const ApiException(
        'Registration failed. Please check your connection and try again.',
      );
    }
  }

  Future<void> logout() async {
    _seedFuture = null;
    _seedUserId = null;
    await _auth.signOut();
  }

  Future<void> ensureCurrentUserProfile({
    String? fullName,
    String? gender,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _runWithTimeout(() async {
      final doc = _users.doc(user.uid);
      final snapshot = await doc.get();
      final normalizedEmail = (user.email ?? '').trim().toLowerCase();
      final username = '@${normalizedEmail.split('@').first}';

      final existing = snapshot.data();
      final displayName = (fullName?.trim().isNotEmpty ?? false)
          ? fullName!.trim()
          : (existing?['fullName']?.toString().trim().isNotEmpty ?? false)
          ? existing!['fullName'].toString()
          : (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : 'ChefInPocket User';

      await doc.set({
        'uid': user.uid,
        'fullName': displayName,
        'email': normalizedEmail,
        'username': existing?['username'] ?? username,
        'gender': gender ?? existing?['gender'] ?? 'prefer_not_to_say',
        'savedRecipes': existing?['savedRecipes'] ?? 0,
        'publishedRecipes': existing?['publishedRecipes'] ?? 0,
        'cookedMeals': existing?['cookedMeals'] ?? 0,
        'createdBy': existing?['createdBy'] ?? user.uid,
        'createdAt': existing?['createdAt'] ?? FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }, 'We could not sync your profile right now. Please try again.');
  }

  Future<void> ensureSeedData() async {
    final user = _requireUser();
    if (_seedUserId != user.uid) {
      _seedUserId = user.uid;
      _seedFuture = null;
    }

    _seedFuture ??= _runWithTimeout(() async {
      final recipeSamples = _sampleRecipes(user.uid);
      final postSamples = _samplePosts(user.uid);
      final recipeSnapshots = await Future.wait(
        recipeSamples.map(
          (recipeData) => _recipes.doc(recipeData['id'] as String).get(),
        ),
      );
      final postSnapshots = await Future.wait(
        postSamples.map(
          (postData) => _communityPosts.doc(postData['id'] as String).get(),
        ),
      );

      final batch = _db.batch();
      var hasWrites = false;

      for (var i = 0; i < recipeSamples.length; i++) {
        if (!recipeSnapshots[i].exists) {
          final recipeData = recipeSamples[i];
          final recipeRef = _recipes.doc(recipeData['id'] as String);
          batch.set(recipeRef, {
            ...recipeData,
            'createdAt': FieldValue.serverTimestamp(),
          });
          hasWrites = true;
        }
      }

      for (var i = 0; i < postSamples.length; i++) {
        if (!postSnapshots[i].exists) {
          final postData = postSamples[i];
          final postRef = _communityPosts.doc(postData['id'] as String);
          batch.set(postRef, {
            ...postData,
            'createdAt': FieldValue.serverTimestamp(),
          });
          hasWrites = true;
        }
      }

      if (hasWrites) {
        await batch.commit();
      }
    }, 'Recipe data could not be prepared. Please check your connection.');

    try {
      await _seedFuture;
    } catch (_) {
      _seedFuture = null;
      rethrow;
    }
  }

  Future<AppContent> fetchContent() async {
    return AppContent.fromJson(_bootstrapContent);
  }

  Future<List<IngredientOption>> fetchIngredients() async {
    return _ingredientOptions
        .map((item) => IngredientOption.fromJson(item))
        .toList();
  }

  Future<List<Recipe>> fetchRecipes() async {
    if (currentUser != null) {
      await ensureSeedData();
    }
    final snapshot = await _recipes
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Stream<List<Recipe>> watchRecipes() async* {
    if (currentUser != null) {
      await ensureSeedData();
    }
    yield* _recipes
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<Recipe> fetchFeaturedRecipe() async {
    final recipes = await fetchRecipes();
    if (recipes.isEmpty) {
      throw const ApiException('No featured recipe is available yet.');
    }

    return recipes.first;
  }

  Future<Recipe> fetchRecipe(String slug) async {
    if (currentUser != null) {
      await ensureSeedData();
    }
    final snapshot = await _recipes.doc(slug).get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw const ApiException('Recipe could not be found.');
    }

    return Recipe.fromJson({...snapshot.data()!, 'id': snapshot.id});
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

  Stream<List<Recipe>> watchMyRecipes() {
    final user = _requireUser();
    final username = '@${(user.email ?? '').split('@').first.toLowerCase()}';
    return _recipes
        .where('authorUsername', isEqualTo: username)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  Stream<List<Recipe>> watchRecipesByAuthor(String username) {
    return _recipes
        .where('authorUsername', isEqualTo: username)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  Future<List<Recipe>> searchRecipesByIngredients(
    List<String> ingredients,
  ) async {
    final recipes = await fetchRecipes();
    return RecipeFilter.filterByAvailableIngredients(
      recipes: recipes,
      availableIngredients: ingredients,
    );
  }

  Future<List<String>> matchIngredientSlugs(List<String> ingredients) async {
    final recipes = await searchRecipesByIngredients(ingredients);
    return recipes.map((recipe) => recipe.id).toList();
  }

  Future<List<ScaledIngredient>> scaleRecipe(String slug, int servings) async {
    final recipe = await fetchRecipe(slug);
    final baseServings = max(1, recipe.servings);
    final factor = servings / baseServings;

    return recipe.ingredients.map((ingredient) {
      final scaledAmount = ingredient.amountPerServing * factor;
      final amountLabel = scaledAmount % 1 == 0
          ? scaledAmount.toStringAsFixed(0)
          : scaledAmount.toStringAsFixed(1);

      return ScaledIngredient(
        name: ingredient.name,
        amount: amountLabel,
        unit: ingredient.unit,
      );
    }).toList();
  }

  Future<String> customizeRecipe(String slug, List<String> replacements) async {
    final recipe = await fetchRecipe(slug);
    if (replacements.isEmpty) {
      return 'No replacements selected for ${recipe.title}.';
    }

    return 'Chef AI updated ${recipe.title} with ${replacements.join(', ')}.';
  }

  Future<Recipe> createRecipe({
    required String title,
    required String ingredients,
    required String cuisine,
    required String prepTime,
    required String servings,
  }) async {
    final user = _requireUser();
    final profile = await fetchProfile();
    final id = _slugify(title);
    final parsedServings = int.tryParse(servings.trim()) ?? 2;
    final ingredientItems = _parseIngredientText(ingredients);
    final recipe = Recipe(
      id: id,
      title: title.trim(),
      subtitle: '$cuisine recipe from the community',
      description: 'A simple $cuisine recipe shared on ChefInPocket.',
      duration: '${prepTime.trim()} min',
      servings: parsedServings,
      tags: [cuisine, 'Easy', 'Community'],
      ingredients: ingredientItems,
      steps: [
        'Prepare the ingredients and measure everything first.',
        'Cook with medium heat and taste as you go.',
        'Plate the dish warm and enjoy your meal.',
      ],
      imageUrl: _recipeImageForCuisine(cuisine),
      authorName: profile.fullName,
      authorUsername: profile.username,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    await _recipes.doc(id).set({
      ...recipe.toJson(),
      'authorUid': user.uid,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _users.doc(user.uid).set({
      'publishedRecipes': FieldValue.increment(1),
    }, SetOptions(merge: true));

    return recipe;
  }

  Future<void> updateRecipe({
    required String recipeId,
    required String title,
    required String ingredients,
    required String cuisine,
    required String prepTime,
    required String servings,
  }) async {
    final user = _requireUser();
    final recipe = await fetchRecipe(recipeId);
    if (recipe.createdBy != user.uid) {
      throw const ApiException('You can only edit your own recipes.');
    }

    final updatedData = {
      'title': title.trim(),
      'subtitle': '$cuisine recipe from the community',
      'description': 'A simple $cuisine recipe shared on ChefInPocket.',
      'duration': '${prepTime.trim()} min',
      'servings': int.tryParse(servings.trim()) ?? recipe.servings,
      'tags': [cuisine, 'Easy', 'Community'],
      'ingredients': _parseIngredientText(
        ingredients,
      ).map((item) => item.toJson()).toList(),
      'imageUrl': _recipeImageForCuisine(cuisine),
      'steps': [
        'Prepare the ingredients and measure everything first.',
        'Cook with medium heat and taste as you go.',
        'Plate the dish warm and enjoy your meal.',
      ],
    };

    await _recipes.doc(recipeId).update(updatedData);

    final posts = await _communityPosts
        .where('recipeSlug', isEqualTo: recipeId)
        .get();
    for (final post in posts.docs) {
      if (post.data()['createdBy'] == user.uid) {
        await post.reference.update({
          'title': title.trim(),
          'description': 'A simple $cuisine recipe shared on ChefInPocket.',
          'imageUrl': _recipeImageForCuisine(cuisine),
        });
      }
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    final user = _requireUser();
    final recipe = await fetchRecipe(recipeId);
    if (recipe.createdBy != user.uid) {
      throw const ApiException('You can only delete your own recipes.');
    }

    await _recipes.doc(recipeId).delete();

    final relatedPosts = await _communityPosts
        .where('recipeSlug', isEqualTo: recipeId)
        .get();
    for (final post in relatedPosts.docs) {
      if (post.data()['createdBy'] == user.uid) {
        await post.reference.delete();
      }
    }

    final relatedSaved = await _savedRecipes
        .where('recipeSlug', isEqualTo: recipeId)
        .get();
    for (final saved in relatedSaved.docs) {
      await saved.reference.delete();
    }

    await _users.doc(user.uid).set({
      'publishedRecipes': FieldValue.increment(-1),
    }, SetOptions(merge: true));
  }

  Future<List<GroceryItem>> fetchGroceryList() async {
    final user = _requireUser();
    final snapshot = await _groceryItems
        .where('createdBy', isEqualTo: user.uid)
        .get();
    return _sortedGroceryItems(snapshot);
  }

  Stream<List<GroceryItem>> watchGroceryList() {
    final user = _requireUser();
    return _groceryItems
        .where('createdBy', isEqualTo: user.uid)
        .snapshots()
        .map(_sortedGroceryItems);
  }

  Future<GroceryItem> addGroceryItem(String title) async {
    final user = _requireUser();
    final doc = _groceryItems.doc();
    final item = GroceryItem(
      id: doc.id,
      title: title.trim(),
      note: 'Added manually',
      emoji: _emojiForIngredient(title),
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    await doc.set({
      ...item.toJson(),
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return item;
  }

  Future<GroceryItem> updateGroceryItem(GroceryItem item) async {
    final user = _requireUser();
    await _groceryItems.doc(item.id).update({
      'title': item.title,
      'note': item.note,
      'emoji': item.emoji,
      'isChecked': item.isChecked,
      'createdBy': user.uid,
    });
    return item;
  }

  Future<void> removeGroceryItem(String id) async {
    await _groceryItems.doc(id).delete();
  }

  Future<List<CommunityPost>> fetchCommunityPosts() async {
    if (currentUser != null) {
      await ensureSeedData();
    }
    final snapshot = await _communityPosts
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CommunityPost.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Stream<List<CommunityPost>> watchCommunityPosts() async* {
    if (currentUser != null) {
      await ensureSeedData();
    }
    yield* _communityPosts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CommunityPost.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  Future<CommunityPost> createCommunityPost({
    required String author,
    required String title,
    required String description,
    required String recipeSlug,
    String role = 'Recipe',
    String? imageUrl,
  }) async {
    final user = _requireUser();
    final profile = await fetchProfile();
    final doc = _communityPosts.doc();
    final normalizedAuthor = author == '@me' || author.trim().isEmpty
        ? profile.username
        : author.trim();

    final post = CommunityPost(
      id: doc.id,
      author: normalizedAuthor,
      role: role,
      title: title.trim(),
      description: description.trim(),
      imageUrl: imageUrl?.trim().isNotEmpty == true
          ? imageUrl!.trim()
          : _recipeImageForCuisine('Other'),
      recipeSlug: recipeSlug.trim().isEmpty ? null : recipeSlug.trim(),
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    await doc.set({
      ...post.toJson(),
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return post;
  }

  Future<List<SavedRecipe>> fetchSavedRecipes() async {
    final user = _requireUser();
    final snapshot = await _savedRecipes
        .where('createdBy', isEqualTo: user.uid)
        .get();
    return _sortedSavedRecipes(snapshot);
  }

  Stream<List<SavedRecipe>> watchSavedRecipes() {
    final user = _requireUser();
    return _savedRecipes
        .where('createdBy', isEqualTo: user.uid)
        .snapshots()
        .map(_sortedSavedRecipes);
  }

  Future<SavedRecipe> saveRecipe(SavedRecipe recipe) async {
    final user = _requireUser();
    final docId = '${user.uid}_${_slugify(recipe.recipeSlug)}';
    final existing = await _savedRecipes.doc(docId).get();
    final payload = {
      ...recipe.toJson(),
      'id': docId,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _savedRecipes.doc(docId).set(payload, SetOptions(merge: true));
    if (!existing.exists) {
      await _users.doc(user.uid).set({
        'savedRecipes': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    return SavedRecipe.fromJson({
      ...payload,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeSavedRecipe(String recipeSlug) async {
    final user = _requireUser();
    final docId = '${user.uid}_${_slugify(recipeSlug)}';
    final existing = await _savedRecipes.doc(docId).get();
    if (!existing.exists) {
      return;
    }

    await _savedRecipes.doc(docId).delete();
    await _users.doc(user.uid).set({
      'savedRecipes': FieldValue.increment(-1),
    }, SetOptions(merge: true));
  }

  Future<UserProfile> fetchProfile() async {
    final user = _requireUser();
    await ensureCurrentUserProfile();

    final userSnapshot = await _users.doc(user.uid).get();
    final baseData = userSnapshot.data() ?? <String, dynamic>{};
    final username = (baseData['username']?.toString().isNotEmpty ?? false)
        ? baseData['username'].toString()
        : '@${(user.email ?? '').split('@').first.toLowerCase()}';
    final publishedSnapshot = await _recipes
        .where('authorUsername', isEqualTo: username)
        .get();
    final savedSnapshot = await _savedRecipes
        .where('createdBy', isEqualTo: user.uid)
        .get();

    return UserProfile.fromJson({
      ...baseData,
      'uid': user.uid,
      'email': user.email ?? baseData['email'],
      'savedRecipes': savedSnapshot.docs.length,
      'publishedRecipes': publishedSnapshot.docs.length,
    });
  }

  Stream<UserProfile?> watchProfile() {
    final user = currentUser;
    if (user == null) {
      return Stream<UserProfile?>.value(null);
    }

    return _users.doc(user.uid).snapshots().asyncMap((_) => fetchProfile());
  }

  Future<void> updateProfile({
    required String fullName,
    required String gender,
  }) async {
    final user = _requireUser();
    await _users.doc(user.uid).set({
      'fullName': fullName.trim(),
      'gender': gender,
    }, SetOptions(merge: true));

    if (fullName.trim().isNotEmpty) {
      await user.updateDisplayName(fullName.trim());
    }
  }

  Future<void> incrementCookedMeals() async {
    final user = _requireUser();
    await _users.doc(user.uid).set({
      'cookedMeals': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<List<ChatMessage>> fetchChatHistory(String context) async {
    final user = _requireUser();
    final snapshot = await _assistantMessages
        .where('createdBy', isEqualTo: user.uid)
        .get();

    final items =
        snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .where((item) => item['context'] == context)
            .toList()
          ..sort((a, b) {
            final left =
                (a['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final right =
                (b['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return left.compareTo(right);
          });

    return items.map(ChatMessage.fromJson).toList();
  }

  Future<ChatMessage> sendAssistantMessage({
    required String context,
    required String message,
    String? recipeSlug,
  }) async {
    final user = _requireUser();
    final recipes = await fetchRecipes();
    final retrieval = AssistantRetrieval.respond(
      recipes: recipes,
      message: message,
      context: context,
      recipeSlug: recipeSlug,
    );

    await _assistantMessages.add({
      'createdBy': user.uid,
      'context': context,
      'recipeSlug': recipeSlug,
      'text': message.trim(),
      'sender': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _assistantMessages.add({
      'createdBy': user.uid,
      'context': context,
      'recipeSlug': recipeSlug,
      'text': retrieval.reply,
      'sender': 'assistant',
      'retrievalMode': 'firestore_lexical',
      'retrievedRecipeIds': retrieval.matches
          .map((match) => match.recipe.id)
          .toList(),
      'retrievedRecipeTitles': retrieval.matches
          .map((match) => match.recipe.title)
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return ChatMessage(text: retrieval.reply, isChef: true);
  }

  List<GroceryItem> _sortedGroceryItems(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs
        .map((doc) => GroceryItem.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    items.sort(
      (a, b) => a.isChecked == b.isChecked
          ? b.createdAt.compareTo(a.createdAt)
          : a.isChecked
          ? 1
          : -1,
    );
    return items;
  }

  List<SavedRecipe> _sortedSavedRecipes(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs
        .map((doc) => SavedRecipe.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ApiException('Please log in to continue.');
    }

    return user;
  }

  Future<T> _runWithTimeout<T>(
    Future<T> Function() action,
    String message,
  ) async {
    try {
      return await action().timeout(_networkTimeout);
    } on FirebaseException catch (error) {
      throw ApiException(_friendlyFirestoreMessage(error));
    } on TimeoutException {
      throw ApiException(message);
    }
  }

  String _friendlyFirestoreMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firebase permissions are blocking this action. Please deploy the Firestore rules for the ChefInPocket project.';
      case 'unavailable':
        return 'Firestore is temporarily unavailable. Please check your internet connection and try again.';
      case 'not-found':
        return 'The requested Firebase document could not be found.';
      case 'failed-precondition':
        return 'Firebase is not fully configured yet. Please check the Firestore setup.';
      default:
        return error.message ??
            'A Firebase database error occurred. Please try again.';
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account was found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _slugify(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  String _normalize(String input) {
    return input.trim().toLowerCase();
  }

  String _emojiForIngredient(String value) {
    final normalized = _normalize(value);
    if (normalized.contains('egg')) {
      return '🥚';
    }
    if (normalized.contains('tomato')) {
      return '🍅';
    }
    if (normalized.contains('onion')) {
      return '🧅';
    }
    if (normalized.contains('garlic')) {
      return '🧄';
    }
    if (normalized.contains('cheese') || normalized.contains('feta')) {
      return '🧀';
    }
    if (normalized.contains('milk')) {
      return '🥛';
    }
    if (normalized.contains('lemon')) {
      return '🍋';
    }
    if (normalized.contains('oil')) {
      return '🫒';
    }
    return '🛒';
  }

  List<IngredientPortion> _parseIngredientText(String ingredients) {
    final parts = ingredients
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return const [
        IngredientPortion(
          name: 'Ingredient',
          amountPerServing: 1,
          unit: 'item',
        ),
      ];
    }

    return parts
        .map(
          (item) =>
              IngredientPortion(name: item, amountPerServing: 1, unit: 'item'),
        )
        .toList();
  }

  String _recipeImageForCuisine(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'turkish':
        return 'https://images.unsplash.com/photo-1546549032-9571cd6b27df?auto=format&fit=crop&w=1200&q=80';
      case 'italian':
        return 'https://images.unsplash.com/photo-1521389508051-d7ffb5dc8f70?auto=format&fit=crop&w=1200&q=80';
      case 'french':
        return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80';
      case 'healthy':
        return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80';
      case 'athlete':
        return 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80';
      default:
        return 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=1200&q=80';
    }
  }

  static const Map<String, dynamic> _bootstrapContent = {
    'homeCategories': [
      {'title': 'Breakfast', 'emoji': '🍳'},
      {'title': 'Quick', 'emoji': '⚡'},
      {'title': 'Healthy', 'emoji': '🥗'},
      {'title': 'Comfort', 'emoji': '🍲'},
    ],
    'cuisineOptions': [
      {'title': 'Turkish', 'emoji': '🇹🇷'},
      {'title': 'Italian', 'emoji': '🍝'},
      {'title': 'French', 'emoji': '🥐'},
      {'title': 'Healthy', 'emoji': '🥗'},
      {'title': 'Athlete', 'emoji': '💪'},
      {'title': 'Other', 'emoji': '🌍'},
    ],
    'quickAccess': [
      {
        'title': 'Browse Cuisines',
        'subtitle': 'Explore recipe collections',
        'iconKey': 'explore_outlined',
        'routeName': AppRoutes.browseCuisine,
      },
      {
        'title': 'Pantry Match',
        'subtitle': 'Cook with what you have',
        'iconKey': 'shopping_basket_outlined',
        'routeName': AppRoutes.ingredientPicker,
      },
      {
        'title': 'Saved Recipes',
        'subtitle': 'Return to your favorites',
        'iconKey': 'bookmark_outline',
        'routeName': AppRoutes.savedRecipes,
      },
      {
        'title': 'Chef Community',
        'subtitle': 'See what others shared',
        'iconKey': 'menu_book_outlined',
        'routeName': AppRoutes.community,
      },
      {
        'title': 'Ask Chef AI',
        'subtitle': 'Get instant cooking help',
        'iconKey': 'auto_awesome_outlined',
        'routeName': AppRoutes.aiChat,
      },
    ],
    'profileMenu': [
      {
        'title': 'Saved Recipes',
        'subtitle': 'Open your personal recipe list',
        'iconKey': 'bookmark_outline',
        'routeName': AppRoutes.savedRecipes,
      },
      {
        'title': 'My Recipes',
        'subtitle': 'Edit or delete your own posts',
        'iconKey': 'menu_book_outlined',
        'routeName': AppRoutes.myRecipes,
      },
      {
        'title': 'Grocery List',
        'subtitle': 'Track missing ingredients',
        'iconKey': 'shopping_cart_checkout_outlined',
        'routeName': AppRoutes.groceryList,
      },
    ],
    'customizationOptions': [
      {
        'ingredient': 'Milk',
        'suggestion': 'Use oat milk for a dairy-free version.',
      },
      {
        'ingredient': 'Butter',
        'suggestion': 'Swap with olive oil for a lighter finish.',
      },
      {
        'ingredient': 'Flour',
        'suggestion': 'Try chickpea flour for extra protein.',
      },
    ],
  };

  static const List<Map<String, dynamic>> _ingredientOptions = [
    {'id': 'eggs', 'title': 'Eggs', 'emoji': '🥚'},
    {'id': 'tomato', 'title': 'Tomato', 'emoji': '🍅'},
    {'id': 'onion', 'title': 'Onion', 'emoji': '🧅'},
    {'id': 'garlic', 'title': 'Garlic', 'emoji': '🧄'},
    {'id': 'feta', 'title': 'Feta', 'emoji': '🧀'},
    {'id': 'spinach', 'title': 'Spinach', 'emoji': '🥬'},
    {'id': 'chicken', 'title': 'Chicken', 'emoji': '🍗'},
    {'id': 'rice', 'title': 'Rice', 'emoji': '🍚'},
    {'id': 'pasta', 'title': 'Pasta', 'emoji': '🍝'},
    {'id': 'lentils', 'title': 'Lentils', 'emoji': '🫘'},
    {'id': 'cucumber', 'title': 'Cucumber', 'emoji': '🥒'},
    {'id': 'pepper', 'title': 'Red Pepper', 'emoji': '🫑'},
    {'id': 'yogurt', 'title': 'Yogurt', 'emoji': '🥛'},
    {'id': 'olive-oil', 'title': 'Olive Oil', 'emoji': '🫒'},
    {'id': 'lemon', 'title': 'Lemon', 'emoji': '🍋'},
    {'id': 'herbs', 'title': 'Fresh Herbs', 'emoji': '🌿'},
  ];

  List<Map<String, dynamic>> _sampleRecipes(String ownerUid) {
    return [
      {
        'id': 'feta-menemen',
        'title': 'Feta Menemen',
        'subtitle': 'Creamy Turkish breakfast skillet',
        'description':
            'Soft eggs, tomatoes, and feta come together in one quick pan.',
        'duration': '18 min',
        'servings': 2,
        'tags': ['Turkish', 'Quick', 'Easy'],
        'ingredients': [
          {'name': 'Eggs', 'amountPerServing': 2, 'unit': 'pcs'},
          {'name': 'Tomatoes', 'amountPerServing': 1, 'unit': 'pcs'},
          {'name': 'Onion', 'amountPerServing': 0.5, 'unit': 'pcs'},
          {'name': 'Feta', 'amountPerServing': 40, 'unit': 'g'},
        ],
        'steps': [
          'Saute onion with olive oil until soft.',
          'Add tomatoes and simmer until thickened.',
          'Stir in eggs gently and crumble feta on top.',
          'Serve immediately with bread.',
        ],
        'imageUrl': _recipeImageForCuisine('turkish'),
        'authorUid': ownerUid,
        'authorName': 'Emir',
        'authorUsername': '@emirie',
        'createdBy': ownerUid,
      },
      {
        'id': 'protein-power-bowl',
        'title': 'Protein Power Bowl',
        'subtitle': 'Athlete-friendly lunch bowl',
        'description':
            'A balanced bowl with chicken, rice, greens, and a lemon yogurt sauce.',
        'duration': '24 min',
        'servings': 2,
        'tags': ['Athlete', 'Healthy', 'Quick'],
        'ingredients': [
          {'name': 'Chicken Breast', 'amountPerServing': 120, 'unit': 'g'},
          {'name': 'Rice', 'amountPerServing': 0.5, 'unit': 'cup'},
          {'name': 'Spinach', 'amountPerServing': 1, 'unit': 'cup'},
          {'name': 'Yogurt', 'amountPerServing': 2, 'unit': 'tbsp'},
        ],
        'steps': [
          'Cook the rice and season the chicken.',
          'Sear the chicken until fully cooked.',
          'Build the bowl with spinach, rice, and sliced chicken.',
          'Finish with lemon yogurt sauce.',
        ],
        'imageUrl': _recipeImageForCuisine('athlete'),
        'authorUid': ownerUid,
        'authorName': 'Selman',
        'authorUsername': '@selmanchef',
        'createdBy': ownerUid,
      },
      {
        'id': 'garden-pasta',
        'title': 'Garden Pasta',
        'subtitle': 'Bright weeknight Italian pasta',
        'description':
            'A fast tomato pasta with herbs, olive oil, and a clean finish.',
        'duration': '20 min',
        'servings': 2,
        'tags': ['Italian', 'Quick', 'Easy'],
        'ingredients': [
          {'name': 'Pasta', 'amountPerServing': 90, 'unit': 'g'},
          {'name': 'Tomatoes', 'amountPerServing': 1.5, 'unit': 'pcs'},
          {'name': 'Garlic', 'amountPerServing': 1, 'unit': 'clove'},
          {'name': 'Fresh Herbs', 'amountPerServing': 1, 'unit': 'handful'},
        ],
        'steps': [
          'Boil the pasta in salted water.',
          'Cook garlic and tomatoes in olive oil.',
          'Toss the pasta with the sauce and herbs.',
          'Serve warm with extra herbs on top.',
        ],
        'imageUrl': _recipeImageForCuisine('italian'),
        'authorUid': ownerUid,
        'authorName': 'Nilsu',
        'authorUsername': '@nilsucooks',
        'createdBy': ownerUid,
      },
      {
        'id': 'red-lentil-soup',
        'title': 'Red Lentil Soup',
        'subtitle': 'Comforting Turkish pantry soup',
        'description':
            'A smooth lentil soup with onion, tomato, and lemon for a cozy meal.',
        'duration': '28 min',
        'servings': 3,
        'tags': ['Turkish', 'Soup', 'Healthy'],
        'ingredients': [
          {'name': 'Lentils', 'amountPerServing': 0.5, 'unit': 'cup'},
          {'name': 'Onion', 'amountPerServing': 0.3, 'unit': 'pcs'},
          {'name': 'Tomatoes', 'amountPerServing': 0.5, 'unit': 'pcs'},
          {'name': 'Lemon', 'amountPerServing': 0.25, 'unit': 'pcs'},
        ],
        'steps': [
          'Saute onion in olive oil until fragrant.',
          'Add lentils and tomatoes with water.',
          'Simmer until the lentils are completely soft.',
          'Blend smooth and finish with fresh lemon.',
        ],
        'imageUrl': _recipeImageForCuisine('turkish'),
        'authorUid': ownerUid,
        'authorName': 'Cem',
        'authorUsername': '@cemplates',
        'createdBy': ownerUid,
      },
      {
        'id': 'herb-omelette',
        'title': 'Fine Herb Omelette',
        'subtitle': 'Light French-style stovetop omelette',
        'description':
            'Soft eggs folded with herbs and feta for a quick cafe-style plate.',
        'duration': '12 min',
        'servings': 1,
        'tags': ['French', 'Breakfast', 'Easy'],
        'ingredients': [
          {'name': 'Eggs', 'amountPerServing': 3, 'unit': 'pcs'},
          {'name': 'Fresh Herbs', 'amountPerServing': 1, 'unit': 'tbsp'},
          {'name': 'Feta', 'amountPerServing': 25, 'unit': 'g'},
          {'name': 'Olive Oil', 'amountPerServing': 1, 'unit': 'tbsp'},
        ],
        'steps': [
          'Whisk the eggs with chopped herbs.',
          'Warm the pan with olive oil over low heat.',
          'Cook gently and fold the omelette with feta inside.',
          'Serve immediately while still soft in the center.',
        ],
        'imageUrl': _recipeImageForCuisine('french'),
        'authorUid': ownerUid,
        'authorName': 'Semse',
        'authorUsername': '@semsekitchen',
        'createdBy': ownerUid,
      },
      {
        'id': 'mediterranean-salad-bowl',
        'title': 'Mediterranean Salad Bowl',
        'subtitle': 'Fresh healthy bowl with crunch and herbs',
        'description':
            'A bright salad bowl with cucumber, tomato, feta, and lemon dressing.',
        'duration': '15 min',
        'servings': 2,
        'tags': ['Healthy', 'Salad', 'Quick'],
        'ingredients': [
          {'name': 'Cucumber', 'amountPerServing': 0.5, 'unit': 'pcs'},
          {'name': 'Tomatoes', 'amountPerServing': 1, 'unit': 'pcs'},
          {'name': 'Feta', 'amountPerServing': 35, 'unit': 'g'},
          {'name': 'Fresh Herbs', 'amountPerServing': 1, 'unit': 'handful'},
        ],
        'steps': [
          'Dice the cucumber and tomatoes into bite-size pieces.',
          'Mix with herbs and crumble feta over the top.',
          'Dress with olive oil and lemon juice.',
          'Toss gently and serve chilled.',
        ],
        'imageUrl': _recipeImageForCuisine('healthy'),
        'authorUid': ownerUid,
        'authorName': 'Bora',
        'authorUsername': '@borabites',
        'createdBy': ownerUid,
      },
    ];
  }

  List<Map<String, dynamic>> _samplePosts(String ownerUid) {
    return [
      {
        'id': 'post-feta-menemen',
        'author': '@emirie',
        'role': 'Recipe',
        'title': 'Feta Menemen',
        'description': 'My favorite soft-scramble breakfast with salty feta.',
        'imageUrl': _recipeImageForCuisine('turkish'),
        'recipeSlug': 'feta-menemen',
        'createdBy': ownerUid,
      },
      {
        'id': 'post-protein-power-bowl',
        'author': '@selmanchef',
        'role': 'Recipe',
        'title': 'Protein Power Bowl',
        'description': 'A quick post-workout bowl with strong macros.',
        'imageUrl': _recipeImageForCuisine('athlete'),
        'recipeSlug': 'protein-power-bowl',
        'createdBy': ownerUid,
      },
      {
        'id': 'post-garden-pasta',
        'author': '@nilsucooks',
        'role': 'Recipe',
        'title': 'Garden Pasta',
        'description': 'Fresh, simple, and perfect for busy evenings.',
        'imageUrl': _recipeImageForCuisine('italian'),
        'recipeSlug': 'garden-pasta',
        'createdBy': ownerUid,
      },
      {
        'id': 'post-red-lentil-soup',
        'author': '@cemplates',
        'role': 'Recipe',
        'title': 'Red Lentil Soup',
        'description': 'Classic Turkish comfort food with a bright lemon finish.',
        'imageUrl': _recipeImageForCuisine('turkish'),
        'recipeSlug': 'red-lentil-soup',
        'createdBy': ownerUid,
      },
      {
        'id': 'post-herb-omelette',
        'author': '@semsekitchen',
        'role': 'Recipe',
        'title': 'Fine Herb Omelette',
        'description': 'A soft French omelette for a quick elegant breakfast.',
        'imageUrl': _recipeImageForCuisine('french'),
        'recipeSlug': 'herb-omelette',
        'createdBy': ownerUid,
      },
      {
        'id': 'post-mediterranean-salad-bowl',
        'author': '@borabites',
        'role': 'Recipe',
        'title': 'Mediterranean Salad Bowl',
        'description': 'Fresh, colorful, and ready in fifteen minutes.',
        'imageUrl': _recipeImageForCuisine('healthy'),
        'recipeSlug': 'mediterranean-salad-bowl',
        'createdBy': ownerUid,
      },
    ];
  }
}
