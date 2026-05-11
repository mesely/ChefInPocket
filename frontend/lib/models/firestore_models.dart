import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileDoc {
  const UserProfileDoc({
    required this.id,
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdBy,
    required this.createdAt,
  });

  factory UserProfileDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data()!;
    return UserProfileDoc(
      id: d['id'] as String? ?? snap.id,
      uid: d['uid'] as String? ?? snap.id,
      fullName: d['fullName'] as String? ?? 'Chef',
      email: d['email'] as String? ?? '',
      createdBy: d['createdBy'] as String? ?? snap.id,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String uid;
  final String fullName;
  final String email;
  final String createdBy;
  final DateTime createdAt;
}

class RecipeDoc {
  const RecipeDoc({
    required this.id,
    required this.title,
    required this.description,
    required this.cuisine,
    required this.duration,
    required this.servings,
    required this.steps,
    required this.ingredients,
    required this.tags,
    required this.imageUrl,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  factory RecipeDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snap) {
    final d = snap.data()!;

    List<String> toStringList(Object? v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    List<Map<String, dynamic>> toMapList(Object? v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }

    return RecipeDoc(
      id: d['id'] as String? ?? snap.id,
      title: d['title'] as String? ?? 'Recipe',
      description: d['description'] as String? ?? '',
      cuisine: d['cuisine'] as String? ?? '',
      duration: d['duration'] as String? ?? '20 min',
      servings: (d['servings'] as num?)?.toInt() ?? 2,
      steps: toStringList(d['steps']),
      ingredients: toMapList(d['ingredients']),
      tags: toStringList(d['tags']),
      imageUrl: d['imageUrl'] as String? ?? '',
      createdBy: d['createdBy'] as String? ?? '',
      createdByName: d['createdByName'] as String? ?? 'Chef',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String description;
  final String cuisine;
  final String duration;
  final int servings;
  final List<String> steps;
  final List<Map<String, dynamic>> ingredients;
  final List<String> tags;
  final String imageUrl;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
}

class SavedRecipeDoc {
  const SavedRecipeDoc({
    this.id = '',
    required this.recipeId,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.role,
    required this.createdBy,
    required this.createdAt,
  });

  factory SavedRecipeDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data()!;
    return SavedRecipeDoc(
      id: d['id'] as String? ?? snap.id,
      recipeId: d['recipeId'] as String? ?? snap.id,
      title: d['title'] as String? ?? 'Saved recipe',
      subtitle: d['subtitle'] as String? ?? '',
      description: d['description'] as String? ?? '',
      imageUrl: d['imageUrl'] as String? ?? '',
      author: d['author'] as String? ?? '@chef',
      role: d['role'] as String? ?? 'Recipe',
      createdBy: d['createdBy'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String recipeId;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String author;
  final String role;
  final String createdBy;
  final DateTime createdAt;
}

class GroceryItemDoc {
  const GroceryItemDoc({
    required this.id,
    required this.title,
    required this.emoji,
    required this.checked,
    required this.createdBy,
    required this.createdAt,
  });

  factory GroceryItemDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data()!;
    return GroceryItemDoc(
      id: d['id'] as String? ?? snap.id,
      title: d['title'] as String? ?? 'Item',
      emoji: d['emoji'] as String? ?? '🛒',
      checked: d['checked'] as bool? ?? false,
      createdBy: d['createdBy'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String emoji;
  final bool checked;
  final String createdBy;
  final DateTime createdAt;
}
