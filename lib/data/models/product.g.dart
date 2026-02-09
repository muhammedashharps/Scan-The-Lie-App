// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      brand: fields[2] as String,
      claims: (fields[3] as List).cast<String>(),
      healthScore: fields[4] as int,
      scanDate: fields[5] as DateTime,
      imageUrl: fields[6] as String?,
      ingredients: (fields[7] as List).cast<Ingredient>(),
      claimVerifications: (fields[8] as List).cast<ClaimVerification>(),
      nutritionFacts: fields[9] as NutritionFacts?,
      imagePath: fields[10] as String?,
      personalAnalysis: fields[11] as PersonalAnalysis?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.claims)
      ..writeByte(4)
      ..write(obj.healthScore)
      ..writeByte(5)
      ..write(obj.scanDate)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.ingredients)
      ..writeByte(8)
      ..write(obj.claimVerifications)
      ..writeByte(9)
      ..write(obj.nutritionFacts)
      ..writeByte(10)
      ..write(obj.imagePath)
      ..writeByte(11)
      ..write(obj.personalAnalysis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IngredientAdapter extends TypeAdapter<Ingredient> {
  @override
  final int typeId = 1;

  @override
  Ingredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingredient(
      name: fields[0] as String,
      purpose: fields[1] as String,
      origin: fields[2] as String,
      controversy: fields[3] as String,
      riskLevel: fields[4] as String,
      bannedCountries: (fields[5] as List).cast<String>(),
      safeLimit: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Ingredient obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.purpose)
      ..writeByte(2)
      ..write(obj.origin)
      ..writeByte(3)
      ..write(obj.controversy)
      ..writeByte(4)
      ..write(obj.riskLevel)
      ..writeByte(5)
      ..write(obj.bannedCountries)
      ..writeByte(6)
      ..write(obj.safeLimit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClaimVerificationAdapter extends TypeAdapter<ClaimVerification> {
  @override
  final int typeId = 2;

  @override
  ClaimVerification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClaimVerification(
      claim: fields[0] as String,
      verdict: fields[1] as String,
      explanation: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClaimVerification obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.claim)
      ..writeByte(1)
      ..write(obj.verdict)
      ..writeByte(2)
      ..write(obj.explanation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimVerificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionFactsAdapter extends TypeAdapter<NutritionFacts> {
  @override
  final int typeId = 3;

  @override
  NutritionFacts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionFacts(
      fat: fields[0] as double?,
      calories: fields[1] as double?,
      carbs: fields[2] as double?,
      protein: fields[3] as double?,
      sugar: fields[4] as double?,
      sodium: fields[5] as double?,
      fiber: fields[6] as double?,
      servingSize: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionFacts obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fat)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.carbs)
      ..writeByte(3)
      ..write(obj.protein)
      ..writeByte(4)
      ..write(obj.sugar)
      ..writeByte(5)
      ..write(obj.sodium)
      ..writeByte(6)
      ..write(obj.fiber)
      ..writeByte(7)
      ..write(obj.servingSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionFactsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PersonalAnalysisAdapter extends TypeAdapter<PersonalAnalysis> {
  @override
  final int typeId = 6;

  @override
  PersonalAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalAnalysis(
      compatibility: fields[0] as String,
      healthConsiderations: (fields[1] as List).cast<HealthConsideration>(),
      recommendations: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PersonalAnalysis obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.compatibility)
      ..writeByte(1)
      ..write(obj.healthConsiderations)
      ..writeByte(2)
      ..write(obj.recommendations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HealthConsiderationAdapter extends TypeAdapter<HealthConsideration> {
  @override
  final int typeId = 7;

  @override
  HealthConsideration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthConsideration(
      title: fields[0] as String,
      description: fields[1] as String,
      severity: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HealthConsideration obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthConsiderationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
