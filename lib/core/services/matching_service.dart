import 'dart:math';

import '../../domain/models/item_model.dart';

class MatchResult {
  final ItemModel lostItem;
  final ItemModel foundItem;
  final double score;
  final Map<String, double> factors;
  final DateTime matchedAt;

  MatchResult({
    required this.lostItem,
    required this.foundItem,
    required this.score,
    required this.factors,
    DateTime? matchedAt,
  }) : matchedAt = matchedAt ?? DateTime.now();

  String get explanation {
    final topFactors = factors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final reasons = <String>[];
    for (final entry in topFactors.take(3)) {
      if (entry.value < 0.3) continue;
      switch (entry.key) {
        case 'title':
          if (entry.value >= 0.7) {
            reasons.add('Very similar item name');
          } else if (entry.value >= 0.4) {
            reasons.add('Similar item name');
          }
          break;
        case 'category':
          if (entry.value >= 0.7) {
            reasons.add('Same category');
          } else if (entry.value >= 0.4) {
            reasons.add('Related category');
          }
          break;
        case 'description':
          if (entry.value >= 0.5) {
            reasons.add('Similar description');
          }
          break;
        case 'location':
          if (entry.value >= 0.7) {
            reasons.add('Same location');
          } else if (entry.value >= 0.4) {
            reasons.add('Nearby location');
          }
          break;
        case 'date':
          if (entry.value >= 0.7) {
            reasons.add('Same date');
          } else if (entry.value >= 0.4) {
            reasons.add('Close date');
          }
          break;
      }
    }

    if (reasons.isEmpty) reasons.add('Partial similarity across fields');
    return reasons.join(' · ');
  }
}

class MatchingService {
  static const Map<String, double> _weights = {
    'title': 0.30,
    'category': 0.20,
    'description': 0.15,
    'location': 0.20,
    'date': 0.15,
  };

  List<MatchResult> findMatches({
    required List<ItemModel> lostItems,
    required List<ItemModel> foundItems,
    int maxResults = 5,
  }) {
    final results = <MatchResult>[];

    for (final lost in lostItems) {
      for (final found in foundItems) {
        if (found.status != 'found') continue;

        final factors = _calculateFactors(lost, found);
        final score = _calculateTotalScore(factors);

        if (score >= 30) {
          results.add(MatchResult(
            lostItem: lost,
            foundItem: found,
            score: score,
            factors: factors,
          ));
        }
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(maxResults).toList();
  }

  List<MatchResult> findMatchesForItem({
    required ItemModel item,
    required List<ItemModel> oppositeItems,
    int maxResults = 5,
  }) {
    final results = <MatchResult>[];

    for (final other in oppositeItems) {
      if (other.status != 'found') continue;
      if (other.createdByUid == item.createdByUid) continue;

      final factors = item.type == 'lost'
          ? _calculateFactors(item, other)
          : _calculateFactors(other, item);
      final score = _calculateTotalScore(factors);

      if (score >= 25) {
        results.add(MatchResult(
          lostItem: item.type == 'lost' ? item : other,
          foundItem: item.type == 'found' ? item : other,
          score: score,
          factors: factors,
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(maxResults).toList();
  }

  Map<String, double> _calculateFactors(ItemModel lost, ItemModel found) {
    return {
      'title': _calculateTitleSimilarity(lost.title, found.title),
      'category': _calculateCategoryMatch(lost.category, found.category),
      'description': _calculateDescriptionSimilarity(lost.description, found.description),
      'location': _calculateLocationMatch(lost.location, found.location),
      'date': _calculateDateProximity(lost.itemDate, found.itemDate),
    };
  }

  double _calculateTotalScore(Map<String, double> factors) {
    double total = 0;
    for (final entry in factors.entries) {
      total += (entry.value * (_weights[entry.key] ?? 0.1));
    }
    return (total * 100).clamp(0, 100);
  }

  double _calculateTitleSimilarity(String title1, String title2) {
    final words1 = _tokenize(title1);
    final words2 = _tokenize(title2);

    if (words1.isEmpty || words2.isEmpty) return 0;

    int matches = 0;
    for (final w1 in words1) {
      for (final w2 in words2) {
        if (w1 == w2 || w1.contains(w2) || w2.contains(w1)) {
          matches++;
          break;
        }
      }
    }

    final jaccard = matches / (words1.length + words2.length - matches);
    final levenshtein = _normalizedLevenshtein(title1.toLowerCase(), title2.toLowerCase());

    return (jaccard * 0.6 + levenshtein * 0.4).clamp(0.0, 1.0);
  }

  double _calculateCategoryMatch(String cat1, String cat2) {
    if (cat1.isEmpty || cat2.isEmpty) return 0;
    if (cat1.toLowerCase() == cat2.toLowerCase()) return 1.0;

    final synonyms = {
      'electronics': ['phone', 'mobile', 'laptop', 'tablet', 'earbuds', 'headphones', 'watch', 'charger', 'camera'],
      'bags': ['backpack', 'handbag', 'purse', 'laptop bag'],
      'clothing': ['jacket', 'hoodie', 'shirt', 'pants', 'shoes', 'cap', 'hat'],
      'accessories': ['glasses', 'sunglasses', 'watch', 'ring', 'necklace', 'bracelet'],
      'documents': ['id', 'card', 'passport', 'license', 'notebook'],
      'keys': ['key', 'keychain', 'car key'],
      'id cards': ['id', 'student id', 'library card', 'badge'],
      'books': ['textbook', 'notebook', 'diary', 'journal'],
    };

    final c1 = cat1.toLowerCase();
    final c2 = cat2.toLowerCase();

    for (final entry in synonyms.entries) {
      final cats = [entry.key, ...entry.value];
      if (cats.contains(c1) && cats.contains(c2)) return 0.7;
    }

    return 0.1;
  }

  double _calculateDescriptionSimilarity(String desc1, String desc2) {
    if (desc1.isEmpty || desc2.isEmpty) return 0;

    final words1 = _tokenize(desc1);
    final words2 = _tokenize(desc2);

    if (words1.isEmpty || words2.isEmpty) return 0;

    final colorWords = {
      'black', 'white', 'blue', 'red', 'green', 'yellow', 'pink', 'purple',
      'orange', 'brown', 'grey', 'gray', 'silver', 'gold', 'navy', 'teal',
      'beige', 'maroon', 'olive', 'cyan', 'magenta', 'tan', 'ivory', 'charcoal',
    };

    final brandWords = {
      'samsung', 'apple', 'iphone', 'ipad', 'airpods', 'galaxy', 'oneplus',
      'sony', 'bose', 'jbl', 'nike', 'adidas', 'puma', 'reebok', 'gucci',
      'zara', 'h&m', 'levi', 'rayban', 'oakley', 'casio', 'fossil',
    };

    int semanticMatches = 0;
    int totalChecks = 0;

    for (final w1 in words1) {
      for (final w2 in words2) {
        totalChecks++;
        if (w1 == w2) {
          semanticMatches += 2;
        } else if (w1.contains(w2) || w2.contains(w1)) {
          semanticMatches++;
        } else if (colorWords.contains(w1) && colorWords.contains(w2)) {
          semanticMatches += (w1 == w2) ? 2 : 0;
        } else if (brandWords.contains(w1) && brandWords.contains(w2)) {
          semanticMatches += (w1 == w2) ? 2 : 0;
        }
      }
    }

    if (totalChecks == 0) return 0;
    return (semanticMatches / (totalChecks * 0.5)).clamp(0.0, 1.0);
  }

  double _calculateLocationMatch(String loc1, String loc2) {
    if (loc1.isEmpty || loc2.isEmpty) return 0;

    final l1 = loc1.toLowerCase().trim();
    final l2 = loc2.toLowerCase().trim();

    if (l1 == l2) return 1.0;

    final words1 = _tokenize(l1);
    final words2 = _tokenize(l2);

    int matches = 0;
    for (final w1 in words1) {
      for (final w2 in words2) {
        if (w1 == w2 || w1.contains(w2) || w2.contains(w1)) {
          matches++;
          break;
        }
      }
    }

    return matches > 0 ? (matches / max(words1.length, words2.length)).clamp(0.0, 1.0) : 0;
  }

  double _calculateDateProximity(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return 0.5;

    final diff = (date1.difference(date2)).inDays.abs();

    if (diff == 0) return 1.0;
    if (diff == 1) return 0.9;
    if (diff <= 3) return 0.7;
    if (diff <= 7) return 0.5;
    if (diff <= 14) return 0.3;
    return 0.1;
  }

  List<String> _tokenize(String text) {
    final stopWords = {'the', 'a', 'an', 'is', 'it', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'and', 'or', 'but', 'not', 'this', 'that', 'was', 'are', 'be', 'has', 'had', 'have', 'from'};

    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toList();
  }

  double _normalizedLevenshtein(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0;

    final len1 = s1.length;
    final len2 = s2.length;

    if (len1 == 0) return 0;
    if (len2 == 0) return 0;

    List<List<int>> dp = List.generate(
      len1 + 1,
      (i) => List.generate(len2 + 1, (j) => 0),
    );

    for (int i = 0; i <= len1; i++) {
      for (int j = 0; j <= len2; j++) {
        if (i == 0) {
          dp[i][j] = j;
        } else if (j == 0) {
          dp[i][j] = i;
        } else {
          int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
          dp[i][j] = min(
            min(dp[i - 1][j] + 1, dp[i][j - 1] + 1),
            dp[i - 1][j - 1] + cost,
          );
        }
      }
    }

    final maxLen = max(len1, len2);
    return 1.0 - (dp[len1][len2] / maxLen);
  }
}
