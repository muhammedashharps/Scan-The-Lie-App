// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 8;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      healthConcerns: (fields[0] as List).cast<String>(),
      allergies: (fields[1] as List).cast<String>(),
      dietaryPreferences: (fields[2] as List).cast<String>(),
      completedQuestionnaire: fields[3] as bool,
      username: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.healthConcerns)
      ..writeByte(1)
      ..write(obj.allergies)
      ..writeByte(2)
      ..write(obj.dietaryPreferences)
      ..writeByte(3)
      ..write(obj.completedQuestionnaire)
      ..writeByte(4)
      ..write(obj.username);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
