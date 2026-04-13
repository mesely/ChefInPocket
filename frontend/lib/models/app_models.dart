import 'package:flutter/material.dart';

IconData appIconFromKey(String? key) {
  switch (key) {
    case 'auto_awesome_outlined':
      return Icons.auto_awesome_outlined;
    case 'bookmark_outline':
      return Icons.bookmark_outline;
    case 'menu_book_outlined':
      return Icons.menu_book_outlined;
    case 'shopping_basket_outlined':
      return Icons.shopping_basket_outlined;
    case 'shopping_cart_checkout_outlined':
      return Icons.shopping_cart_checkout_outlined;
    case 'spa_outlined':
      return Icons.spa_outlined;
    case 'notifications_none':
      return Icons.notifications_none;
    case 'explore_outlined':
    default:
      return Icons.explore_outlined;
  }
}

String _asString(Object? value, [String fallback = '']) {
  if (value == null) {
    return fallback;
  }

  return value.toString();
}

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(_asString(value)) ?? fallback;
}

int _asInt(Object? value, [int fallback = 0]) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(_asString(value)) ?? fallback;
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }

  return const [];
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  return const [];
}

class AppContent {
  const AppContent({
    required this.homeCategories,
    required this.cuisineOptions,
    required this.quickAccess,
    required this.profileMenu,
    required this.customizationOptions,
  });

  factory AppContent.fromJson(Map<String, dynamic> json) {
    return AppContent(
      homeCategories:
          _mapList(json['homeCategories']).map(CategoryItem.fromJson).toList(),
      cuisineOptions:
          _mapList(json['cuisineOptions']).map(CategoryItem.fromJson).toList(),
      quickAccess:
          _mapList(json['quickAccess']).map(FeatureCardItem.fromJson).toList(),
      profileMenu:
          _mapList(json['profileMenu']).map(ProfileMenuEntry.fromJson).toList(),
      customizationOptions: _mapList(json['customizationOptions'])
          .map(CustomizationOption.fromJson)
          .toList(),
    );
  }

  final List<CategoryItem> homeCategories;
  final List<CategoryItem> cuisineOptions;
  final List<FeatureCardItem> quickAccess;
  final List<ProfileMenuEntry> profileMenu;
  final List<CustomizationOption> customizationOptions;
}

class CategoryItem {
  const CategoryItem({
    required this.title,
    required this.emoji,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      title: _asString(json['title'], 'Category'),
      emoji: _asString(json['emoji'], '🍽️'),
    );
  }

  final String title;
  final String emoji;
}

class FeatureCardItem {
  const FeatureCardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
  });

  factory FeatureCardItem.fromJson(Map<String, dynamic> json) {
    return FeatureCardItem(
      title: _asString(json['title'], 'Feature'),
      subtitle: _asString(json['subtitle']),
      icon: appIconFromKey(_asString(json['iconKey'])),
      routeName: _asString(json['routeName'], '/home'),
    );
  }

  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;
}

class IngredientOption {
  const IngredientOption({
    required this.id,
    required this.title,
    required this.emoji,
  });

  factory IngredientOption.fromJson(Map<String, dynamic> json) {
    return IngredientOption(
      id: _asString(json['ingredientId'] ?? json['id']),
      title: _asString(json['title'], 'Ingredient'),
      emoji: _asString(json['emoji'], '🛒'),
    );
  }

  final String id;
  final String title;
  final String emoji;
}

class IngredientPortion {
  const IngredientPortion({
    required this.name,
    required this.amountPerServing,
    required this.unit,
  });

  factory IngredientPortion.fromJson(Map<String, dynamic> json) {
    return IngredientPortion(
      name: _asString(json['name'], 'Ingredient'),
      amountPerServing: _asDouble(json['amount'] ?? json['amountPerServing']),
      unit: _asString(json['unit']),
    );
  }

  final String name;
  final double amountPerServing;
  final String unit;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.duration,
    required this.servings,
    required this.tags,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: _asString(json['slug'] ?? json['id'] ?? json['_id']),
      title: _asString(json['title'], 'Recipe'),
      subtitle: _asString(json['subtitle']),
      description: _asString(json['description']),
      duration: _asString(json['duration'], '20 min'),
      servings: _asInt(json['servings'], 2),
      tags: _stringList(json['tags']),
      ingredients:
          _mapList(json['ingredients']).map(IngredientPortion.fromJson).toList(),
      steps: _stringList(json['steps']),
      imageUrl: _asString(json['imageUrl']),
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String duration;
  final int servings;
  final List<String> tags;
  final List<IngredientPortion> ingredients;
  final List<String> steps;
  final String imageUrl;
}

class ScaledIngredient {
  const ScaledIngredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory ScaledIngredient.fromJson(Map<String, dynamic> json) {
    return ScaledIngredient(
      name: _asString(json['name'], 'Ingredient'),
      amount: _asString(json['amount']),
      unit: _asString(json['unit']),
    );
  }

  final String name;
  final String amount;
  final String unit;

  String get label => unit.isEmpty ? amount : '$amount $unit';
}

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.title,
    required this.note,
    required this.emoji,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: _asString(json['_id'] ?? json['itemId'] ?? json['id']),
      title: _asString(json['title'], 'Grocery item'),
      note: _asString(json['note'], 'Added manually'),
      emoji: _asString(json['emoji'], '🛒'),
    );
  }

  final String id;
  final String title;
  final String note;
  final String emoji;
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isChef,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: _asString(json['text']),
      isChef: json['isChef'] == true || json['sender'] == 'assistant',
    );
  }

  final String text;
  final bool isChef;
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.author,
    required this.role,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.recipeSlug,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: _asString(json['_id'] ?? json['id'] ?? json['seedKey']),
      author: _asString(json['author'], '@chef'),
      role: _asString(json['role'], 'Recipe'),
      title: _asString(json['title'], 'Community recipe'),
      description: _asString(json['description']),
      imageUrl: _asString(json['imageUrl']),
      recipeSlug: _asString(json['recipeSlug']).isEmpty
          ? null
          : _asString(json['recipeSlug']),
    );
  }

  final String id;
  final String author;
  final String role;
  final String title;
  final String description;
  final String imageUrl;
  final String? recipeSlug;
}

class SavedRecipe {
  const SavedRecipe({
    required this.recipeSlug,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.role,
  });

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      recipeSlug: _asString(json['recipeSlug']),
      title: _asString(json['title'], 'Saved recipe'),
      subtitle: _asString(json['subtitle']),
      description: _asString(json['description']),
      imageUrl: _asString(json['imageUrl']),
      author: _asString(json['author'], '@selmancooks'),
      role: _asString(json['role'], 'Saved recipe'),
    );
  }

  factory SavedRecipe.fromRecipe(
    Recipe recipe, {
    String author = '@selmancooks',
    String role = 'Recipe',
  }) {
    return SavedRecipe(
      recipeSlug: recipe.id,
      title: recipe.title,
      subtitle: recipe.subtitle,
      description: recipe.description,
      imageUrl: recipe.imageUrl,
      author: author,
      role: role,
    );
  }

  factory SavedRecipe.fromPost(CommunityPost post) {
    return SavedRecipe(
      recipeSlug: post.recipeSlug ?? post.id,
      title: post.title,
      subtitle: post.role,
      description: post.description,
      imageUrl: post.imageUrl,
      author: post.author,
      role: post.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeSlug': recipeSlug,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'imageUrl': imageUrl,
      'author': author,
      'role': role,
    };
  }

  final String recipeSlug;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String author;
  final String role;
}

class ProfileMenuEntry {
  const ProfileMenuEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.routeName,
  });

  factory ProfileMenuEntry.fromJson(Map<String, dynamic> json) {
    final routeName = _asString(json['routeName']);

    return ProfileMenuEntry(
      title: _asString(json['title'], 'Profile'),
      subtitle: _asString(json['subtitle']),
      icon: appIconFromKey(_asString(json['iconKey'])),
      routeName: routeName.isEmpty ? null : routeName,
    );
  }

  final String title;
  final String subtitle;
  final IconData icon;
  final String? routeName;
}

class CustomizationOption {
  const CustomizationOption({
    required this.ingredient,
    required this.suggestion,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      ingredient: _asString(json['ingredient'], 'Ingredient'),
      suggestion: _asString(json['suggestion']),
    );
  }

  final String ingredient;
  final String suggestion;
}

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.savedRecipes,
    required this.publishedRecipes,
    required this.cookedMeals,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: _asString(json['fullName'], 'ChefInPocket User'),
      email: _asString(json['email'], 'selman@example.com'),
      savedRecipes: _asInt(json['savedRecipes']),
      publishedRecipes: _asInt(json['publishedRecipes']),
      cookedMeals: _asInt(json['cookedMeals']),
    );
  }

  final String fullName;
  final String email;
  final int savedRecipes;
  final int publishedRecipes;
  final int cookedMeals;
}
