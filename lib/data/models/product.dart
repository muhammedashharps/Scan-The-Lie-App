import 'package:hive/hive.dart';

part 'product.g.dart';

/// Risk level for ingredients
enum RiskLevel {
  low,
  moderate,
  high,
}

/// Claim verdict types
enum ClaimVerdict {
  verified, // True claim
  misleading,
  falseClaim, // Changed from 'false' to avoid keyword conflict
}

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String brand;

  @HiveField(3)
  final List<String> claims;

  @HiveField(4)
  final int healthScore;

  @HiveField(5)
  final DateTime scanDate;

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7)
  final List<Ingredient> ingredients;

  @HiveField(8)
  final List<ClaimVerification> claimVerifications;

  @HiveField(9)
  final NutritionFacts? nutritionFacts;

  @HiveField(10)
  final String? imagePath;

  @HiveField(11)
  final PersonalAnalysis? personalAnalysis;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.claims,
    required this.healthScore,
    required this.scanDate,
    this.imageUrl,
    required this.ingredients,
    required this.claimVerifications,
    this.nutritionFacts,
    this.imagePath,
    this.personalAnalysis,
  });

  /// Get health score category
  String get healthCategory {
    if (healthScore >= 70) return 'Good';
    if (healthScore >= 40) return 'Average';
    return 'Poor';
  }

  /// Get color-coded score description
  String get scoreEmoji {
    if (healthScore >= 70) return '😎';
    if (healthScore >= 40) return '😐';
    return '💀';
  }
}

@HiveType(typeId: 1)
class Ingredient extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String purpose;

  @HiveField(2)
  final String origin;

  @HiveField(3)
  final String controversy;

  @HiveField(4)
  final String riskLevel; // 'low', 'moderate', 'high'

  @HiveField(5)
  final List<String> bannedCountries;

  @HiveField(6)
  final String safeLimit;

  Ingredient({
    required this.name,
    required this.purpose,
    required this.origin,
    required this.controversy,
    required this.riskLevel,
    required this.bannedCountries,
    required this.safeLimit,
  });

  RiskLevel get risk {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return RiskLevel.high;
      case 'moderate':
        return RiskLevel.moderate;
      default:
        return RiskLevel.low;
    }
  }
}

@HiveType(typeId: 2)
class ClaimVerification extends HiveObject {
  @HiveField(0)
  final String claim;

  @HiveField(1)
  final String verdict; // 'true', 'misleading', 'false'

  @HiveField(2)
  final String explanation;

  ClaimVerification({
    required this.claim,
    required this.verdict,
    required this.explanation,
  });

  ClaimVerdict get verdictType {
    switch (verdict.toLowerCase()) {
      case 'true':
      case 'verified':
        return ClaimVerdict.verified;
      case 'misleading':
        return ClaimVerdict.misleading;
      default:
        return ClaimVerdict.falseClaim;
    }
  }

  String get verdictEmoji {
    switch (verdictType) {
      case ClaimVerdict.verified:
        return '✅';
      case ClaimVerdict.misleading:
        return '⚠️';
      case ClaimVerdict.falseClaim:
        return '❌';
    }
  }
}

@HiveType(typeId: 3)
class NutritionFacts extends HiveObject {
  @HiveField(0)
  final double? fat;

  @HiveField(1)
  final double? calories;

  @HiveField(2)
  final double? carbs;

  @HiveField(3)
  final double? protein;

  @HiveField(4)
  final double? sugar;

  @HiveField(5)
  final double? sodium;

  @HiveField(6)
  final double? fiber;

  @HiveField(7)
  final String? servingSize;

  NutritionFacts({
    this.fat,
    this.calories,
    this.carbs,
    this.protein,
    this.sugar,
    this.sodium,
    this.fiber,
    this.servingSize,
  });
}

@HiveType(typeId: 6)
class PersonalAnalysis extends HiveObject {
  @HiveField(0)
  final String compatibility; // 'High', 'Medium', 'Low'

  @HiveField(1)
  final List<HealthConsideration> healthConsiderations;

  @HiveField(2)
  final List<String> recommendations;

  PersonalAnalysis({
    required this.compatibility,
    required this.healthConsiderations,
    required this.recommendations,
  });
}

@HiveType(typeId: 7)
class HealthConsideration extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String severity; // 'critical', 'warning', 'info'

  HealthConsideration({
    required this.title,
    required this.description,
    required this.severity,
  });
}
