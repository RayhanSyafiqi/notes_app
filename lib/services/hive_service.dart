import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/note.dart';

class HiveService {
  static const String userBoxName = 'users';
  static const String noteBoxName = 'notes';
  static const String settingsBoxName = 'settings';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(NoteAdapter());

    // Open boxes
    await Hive.openBox<User>(userBoxName);
    await Hive.openBox<Note>(noteBoxName);
    await Hive.openBox(settingsBoxName); // For app settings
  }

  // Get boxes
  static Box<User> get userBox => Hive.box<User>(userBoxName);
  static Box<Note> get noteBox => Hive.box<Note>(noteBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  // Close all boxes (call when app is terminated)
  static Future<void> close() async {
    await Hive.close();
  }
}
