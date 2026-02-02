import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'time_entry.g.dart';

@HiveType(typeId: 0)
class TimeEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String type; // 'invested' or 'spent'

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final DateTime startTime;

  @HiveField(6)
  final String? notes;

  TimeEntry({
    String? id,
    required this.title,
    required this.category,
    required this.type,
    required this.durationMinutes,
    required this.startTime,
    this.notes,
  }) : id = id ?? const Uuid().v4();
}
