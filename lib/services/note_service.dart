import '../models/note.dart';
import 'api_service.dart';

class NoteService {
  static Future<List<Note>> getNotes({
    int page = 1,
    int limit = 100, // Get more notes for local display
    String? search,
  }) async {
    final response = await ApiService.getNotes(
      page: page,
      limit: limit,
      search: search,
    );

    if (response['success']) {
      final data = response['data'];
      final List<dynamic> notesJson = data['notes'];

      return notesJson.map((json) => Note.fromJson(json)).toList();
    }

    return [];
  }

  static Future<Note?> getNoteById(String id) async {
    final response = await ApiService.getNoteById(id);

    if (response['success']) {
      final noteData = response['data']['note'];
      return Note.fromJson(noteData);
    }

    return null;
  }

  static Future<Note?> createNote({
    required String title,
    required String content,
  }) async {
    final response = await ApiService.createNote(
      title: title,
      content: content,
    );

    if (response['success']) {
      final noteData = response['data']['note'];
      return Note.fromJson(noteData);
    }

    return null;
  }

  static Future<Note?> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final response = await ApiService.updateNote(
      id: id,
      title: title,
      content: content,
    );

    if (response['success']) {
      final noteData = response['data']['note'];
      return Note.fromJson(noteData);
    }

    return null;
  }

  static Future<bool> deleteNote(String id) async {
    final response = await ApiService.deleteNote(id);
    return response['success'];
  }

  static Future<List<Note>> searchNotes(String query) async {
    return await getNotes(search: query);
  }

  static String getErrorMessage(Map<String, dynamic> response) {
    return response['message'] ?? 'An error occurred';
  }
}
