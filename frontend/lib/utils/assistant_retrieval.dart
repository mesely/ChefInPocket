import '../models/app_models.dart';

class RetrievedRecipeMatch {
  const RetrievedRecipeMatch({
    required this.recipe,
    required this.score,
    required this.matchedTerms,
  });

  final Recipe recipe;
  final int score;
  final List<String> matchedTerms;
}

class AssistantRetrievalResult {
  const AssistantRetrievalResult({required this.reply, required this.matches});

  final String reply;
  final List<RetrievedRecipeMatch> matches;
}

/// Lightweight retrieval layer used by the in-app cooking assistant.
/// It retrieves relevant recipes from Firestore-backed app data before
/// building the final answer.
class AssistantRetrieval {
  AssistantRetrieval._();

  static AssistantRetrievalResult respond({
    required List<Recipe> recipes,
    required String message,
    required String context,
    String? recipeSlug,
  }) {
    final matches = retrieve(
      recipes: recipes,
      message: message,
      context: context,
      recipeSlug: recipeSlug,
    );

    final reply = buildReply(
      message: message,
      context: context,
      recipeSlug: recipeSlug,
      matches: matches,
    );

    return AssistantRetrievalResult(reply: reply, matches: matches);
  }

  static List<RetrievedRecipeMatch> retrieve({
    required List<Recipe> recipes,
    required String message,
    required String context,
    String? recipeSlug,
  }) {
    final queryTerms = _tokenize('$message $context ${recipeSlug ?? ''}');
    final normalizedSlug = _normalize(recipeSlug ?? '');
    final normalizedContext = _normalize(context);

    final scoredMatches = <RetrievedRecipeMatch>[];

    for (final recipe in recipes) {
      final matchedTerms = <String>{};
      var score = 0;

      final normalizedId = _normalize(recipe.id);
      final normalizedTitle = _normalize(recipe.title);
      final normalizedSubtitle = _normalize(recipe.subtitle);
      final normalizedDescription = _normalize(recipe.description);
      final normalizedTags = recipe.tags.map(_normalize).toList();
      final normalizedIngredients = recipe.ingredients
          .map((ingredient) => _normalize(ingredient.name))
          .toList();
      final normalizedSteps = recipe.steps.map(_normalize).toList();

      if (normalizedSlug.isNotEmpty && normalizedId == normalizedSlug) {
        score += 100;
        matchedTerms.add(recipe.id);
      }

      if (normalizedContext.isNotEmpty &&
          (normalizedTitle.contains(normalizedContext) ||
              normalizedContext.contains(normalizedTitle))) {
        score += 80;
        matchedTerms.add(recipe.title);
      }

      for (final term in queryTerms) {
        if (term.length < 2) {
          continue;
        }

        if (normalizedId.contains(term)) {
          score += 10;
          matchedTerms.add(term);
        }

        if (normalizedTitle.contains(term)) {
          score += 14;
          matchedTerms.add(term);
        }

        if (normalizedSubtitle.contains(term)) {
          score += 8;
          matchedTerms.add(term);
        }

        if (normalizedDescription.contains(term)) {
          score += 6;
          matchedTerms.add(term);
        }

        if (normalizedTags.any((tag) => tag.contains(term))) {
          score += 7;
          matchedTerms.add(term);
        }

        if (normalizedIngredients.any(
          (ingredient) => ingredient.contains(term),
        )) {
          score += 12;
          matchedTerms.add(term);
        }

        if (normalizedSteps.any((step) => step.contains(term))) {
          score += 4;
          matchedTerms.add(term);
        }
      }

      if (score > 0) {
        scoredMatches.add(
          RetrievedRecipeMatch(
            recipe: recipe,
            score: score,
            matchedTerms: matchedTerms.toList()..sort(),
          ),
        );
      }
    }

    scoredMatches.sort((a, b) => b.score.compareTo(a.score));
    return scoredMatches.take(3).toList();
  }

  static String buildReply({
    required String message,
    required String context,
    required List<RetrievedRecipeMatch> matches,
    String? recipeSlug,
  }) {
    final normalizedMessage = _normalize(message);
    final primaryMatch = matches.isEmpty ? null : matches.first.recipe;

    if (primaryMatch == null) {
      return 'I could not retrieve a strong recipe match yet. Try asking about ingredients, time, servings, or substitutions.';
    }

    final sourceLine = _buildSourceLine(matches);

    if (_containsAny(normalizedMessage, [
      'ingredient',
      'need',
      'what do i need',
    ])) {
      final ingredients = primaryMatch.ingredients
          .map((ingredient) => ingredient.name)
          .take(6)
          .join(', ');
      return '${primaryMatch.title} uses $ingredients. $sourceLine';
    }

    if (_containsAny(normalizedMessage, [
      'substitute',
      'replace',
      'swap',
      'instead of',
    ])) {
      final suggestion = _substitutionFor(primaryMatch, normalizedMessage);
      return '$suggestion $sourceLine';
    }

    if (_containsAny(normalizedMessage, [
      'how long',
      'time',
      'minutes',
      'cook',
    ])) {
      final firstStep = primaryMatch.steps.isEmpty
          ? 'Cook on medium heat and taste as you go.'
          : primaryMatch.steps.first;
      return '${primaryMatch.title} takes about ${primaryMatch.duration} and serves ${primaryMatch.servings}. Start with: $firstStep $sourceLine';
    }

    if (_containsAny(normalizedMessage, [
      'step',
      'how do i make',
      'how to make',
    ])) {
      final steps = primaryMatch.steps.take(3).toList();
      if (steps.isEmpty) {
        return 'I retrieved ${primaryMatch.title}, but its steps are currently minimal. Use medium heat, add ingredients gradually, and season at the end. $sourceLine';
      }

      return 'For ${primaryMatch.title}, here is a quick path: 1) ${steps[0]}${steps.length > 1 ? ' 2) ${steps[1]}' : ''}${steps.length > 2 ? ' 3) ${steps[2]}' : ''} $sourceLine';
    }

    if (_containsAny(normalizedMessage, ['serve', 'serving', 'portion'])) {
      return '${primaryMatch.title} is currently stored as a ${primaryMatch.servings}-serving recipe. You can also use the Adjust Servings tool from the recipe detail page. $sourceLine';
    }

    final ingredientPreview = primaryMatch.ingredients
        .map((ingredient) => ingredient.name)
        .take(4)
        .join(', ');
    return 'I retrieved ${primaryMatch.title} for "$context". It is a ${primaryMatch.tags.join(', ')} recipe built around $ingredientPreview. $sourceLine';
  }

  static String _buildSourceLine(List<RetrievedRecipeMatch> matches) {
    final titles = matches.map((match) => match.recipe.title).join(', ');
    return 'Retrieved from: $titles.';
  }

  static String _substitutionFor(Recipe recipe, String normalizedMessage) {
    final ingredients = recipe.ingredients
        .map((ingredient) => ingredient.name)
        .toList();

    if (normalizedMessage.contains('feta')) {
      return 'For ${recipe.title}, you can replace feta with white cheese, ricotta, or a mild goat cheese depending on how creamy you want it.';
    }

    if (normalizedMessage.contains('egg')) {
      return 'For ${recipe.title}, eggs are central to the texture, but a soft tofu scramble is the closest plant-based substitute.';
    }

    if (normalizedMessage.contains('tomato')) {
      return 'For ${recipe.title}, canned tomatoes or roasted red peppers can work if fresh tomatoes are unavailable.';
    }

    if (normalizedMessage.contains('yogurt')) {
      return 'For ${recipe.title}, plain strained yogurt can be replaced with Greek yogurt or a light labneh-style sauce.';
    }

    if (ingredients.isNotEmpty) {
      final firstIngredient = ingredients.first;
      return 'For ${recipe.title}, start by replacing $firstIngredient with an ingredient that has a similar moisture level and cooking behavior.';
    }

    return 'For ${recipe.title}, use a substitute with similar texture and cooking time so the recipe stays balanced.';
  }

  static bool _containsAny(String text, List<String> patterns) {
    return patterns.any(text.contains);
  }

  static List<String> _tokenize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
