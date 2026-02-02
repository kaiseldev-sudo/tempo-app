// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 1;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      currentXp: fields[0] as int,
      totalFocusMinutes: fields[1] as int,
      tasksCompleted: fields[2] as int,
      sessionsCompleted: fields[3] as int,
      dailyStreak: fields[4] as int,
      unlockedBadgeIds: (fields[5] as List).cast<String>(),
      lastLoginMs: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.currentXp)
      ..writeByte(1)
      ..write(obj.totalFocusMinutes)
      ..writeByte(2)
      ..write(obj.tasksCompleted)
      ..writeByte(3)
      ..write(obj.sessionsCompleted)
      ..writeByte(4)
      ..write(obj.dailyStreak)
      ..writeByte(5)
      ..write(obj.unlockedBadgeIds)
      ..writeByte(6)
      ..write(obj.lastLoginMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
