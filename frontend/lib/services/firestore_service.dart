import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/firestore_models.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ── Collections ───────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _db.collection('recipes');

  CollectionReference<Map<String, dynamic>> _savedRecipes(String uid) =>
      _db.collection('savedRecipes').doc(uid).collection('items');

  CollectionReference<Map<String, dynamic>> _groceryItems(String uid) =>
      _db.collection('groceryItems').doc(uid).collection('items');

  // ── User profile ──────────────────────────────────────────────────────────

  Future<void> saveUserProfile({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    await _users.doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserProfileDoc?> fetchUserProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    return UserProfileDoc.fromFirestore(snap);
  }

  // ── Recipes (CRUD) ────────────────────────────────────────────────────────

  Future<RecipeDoc> createRecipe({
    required String title,
    required String description,
    required String cuisine,
    required String duration,
    required int servings,
    required List<String> steps,
    required List<Map<String, dynamic>> ingredients,
    required List<String> tags,
    String imageUrl = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final ref = _recipes.doc();
    final data = {
      'id': ref.id,
      'title': title,
      'description': description,
      'cuisine': cuisine,
      'duration': duration,
      'servings': servings,
      'steps': steps,
      'ingredients': ingredients,
      'tags': tags,
      'imageUrl': imageUrl,
      'createdBy': user.uid,
      'createdByName': user.displayName ?? user.email ?? 'Chef',
      'createdAt': FieldValue.serverTimestamp(),
    };
    await ref.set(data);
    return RecipeDoc(
      id: ref.id,
      title: title,
      description: description,
      cuisine: cuisine,
      duration: duration,
      servings: servings,
      steps: steps,
      ingredients: ingredients,
      tags: tags,
      imageUrl: imageUrl,
      createdBy: user.uid,
      createdByName: user.displayName ?? user.email ?? 'Chef',
      createdAt: DateTime.now(),
    );
  }

  Stream<List<RecipeDoc>> streamMyRecipes() {
    return _recipes
        .where('createdBy', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RecipeDoc.fromFirestore).toList());
  }

  Stream<List<RecipeDoc>> streamAllRecipes() {
    return _recipes
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RecipeDoc.fromFirestore).toList());
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipes.doc(recipeId).delete();
  }

  Future<void> updateRecipe(String recipeId, {required String title, required String description}) async {
    await _recipes.doc(recipeId).update({
      'title': title,
      'description': description,
    });
  }

  // ── Saved recipes (CRUD) ──────────────────────────────────────────────────

  Stream<List<SavedRecipeDoc>> streamSavedRecipes() {
    return _savedRecipes(_uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(SavedRecipeDoc.fromFirestore).toList());
  }

  Future<void> saveRecipe(SavedRecipeDoc recipe) async {
    final ref = _savedRecipes(_uid).doc(recipe.recipeId);
    await ref.set({
      'recipeId': recipe.recipeId,
      'title': recipe.title,
      'subtitle': recipe.subtitle,
      'description': recipe.description,
      'imageUrl': recipe.imageUrl,
      'author': recipe.author,
      'role': recipe.role,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unsaveRecipe(String recipeId) async {
    await _savedRecipes(_uid).doc(recipeId).delete();
  }

  Future<bool> isRecipeSaved(String recipeId) async {
    final doc = await _savedRecipes(_uid).doc(recipeId).get();
    return doc.exists;
  }

  // ── Grocery list (CRUD) ───────────────────────────────────────────────────

  Stream<List<GroceryItemDoc>> streamGroceryItems() {
    return _groceryItems(_uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(GroceryItemDoc.fromFirestore).toList());
  }

  Future<GroceryItemDoc> addGroceryItem({required String title, String emoji = '🛒'}) async {
    final ref = _groceryItems(_uid).doc();
    final now = DateTime.now();
    await ref.set({
      'id': ref.id,
      'title': title,
      'emoji': emoji,
      'checked': false,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return GroceryItemDoc(
      id: ref.id,
      title: title,
      emoji: emoji,
      checked: false,
      createdBy: _uid,
      createdAt: now,
    );
  }

  Future<void> toggleGroceryItem(String itemId, bool checked) async {
    await _groceryItems(_uid).doc(itemId).update({'checked': checked});
  }

  Future<void> deleteGroceryItem(String itemId) async {
    await _groceryItems(_uid).doc(itemId).delete();
  }
}
