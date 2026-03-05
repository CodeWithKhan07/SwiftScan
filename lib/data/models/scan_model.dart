import 'package:hive/hive.dart';

part 'scan_model.g.dart';

@HiveType(typeId: 0)
class ScanModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String rawText;

  @HiveField(3)
  final String imagePath;

  @HiveField(4)
  final DateTime dateTime;

  @HiveField(5)
  final List<String> detectedDates;

  @HiveField(6)
  final List<String> detectedTasks;

  @HiveField(7)
  final String category;

  @HiveField(8)
  final bool isPinned;

  ScanModel({
    required this.id,
    required this.title,
    required this.rawText,
    required this.imagePath,
    required this.dateTime,
    this.detectedDates = const [],
    this.detectedTasks = const [],
    this.category = 'General',
    this.isPinned = false,
  });

  ScanModel copyWith({
    String? id,
    String? title,
    String? rawText,
    String? imagePath,
    DateTime? dateTime,
    List<String>? detectedDates,
    List<String>? detectedTasks,
    String? category,
    bool? isPinned,
  }) {
    return ScanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      rawText: rawText ?? this.rawText,
      imagePath: imagePath ?? this.imagePath,
      dateTime: dateTime ?? this.dateTime,
      detectedDates: detectedDates ?? this.detectedDates,
      detectedTasks: detectedTasks ?? this.detectedTasks,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
