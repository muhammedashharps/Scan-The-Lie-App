import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 8)
class UserPreferences extends HiveObject {
  @HiveField(0)
  List<String> healthConcerns;

  @HiveField(1)
  List<String> allergies;

  @HiveField(2)
  List<String> dietaryPreferences;

  @HiveField(3)
  bool completedQuestionnaire;

  @HiveField(4)
  String? username;

  UserPreferences({
    this.healthConcerns = const [],
    this.allergies = const [],
    this.dietaryPreferences = const [],
    this.completedQuestionnaire = false,
    this.username,
  });
}
