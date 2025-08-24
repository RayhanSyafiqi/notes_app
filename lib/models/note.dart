import 'package:hive/hive.dart';

part 'note.g.dart'; // Generated file

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId; // Foreign key to User

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String content;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime lastEdited;

  @HiveField(6)
  late bool isDeleted; // Soft delete

  @HiveField(7)
  late String category; // Optional: untuk kategorisasi notes

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.lastEdited,
    this.isDeleted = false,
    this.category = 'general',
  });

  Note.create({
    required this.userId,
    required this.title,
    required this.content,
    this.category = 'general',
  }) {
    id = DateTime.now().millisecondsSinceEpoch.toString();
    createdAt = DateTime.now();
    lastEdited = DateTime.now();
    isDeleted = false;
  }

  void updateNote({String? title, String? content, String? category}) {
    if (title != null) this.title = title;
    if (content != null) this.content = content;
    if (category != null) this.category = category;
    lastEdited = DateTime.now();
    save(); // Hive method to save changes
  }

  void softDelete() {
    isDeleted = true;
    lastEdited = DateTime.now();
    save();
  }

  void restore() {
    isDeleted = false;
    lastEdited = DateTime.now();
    save();
  }
}
