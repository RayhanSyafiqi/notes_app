import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/note.dart';
import '../services/hive_service.dart';

class NoteRepository {
  static Box<Note> get _box => HiveService.noteBox;

  // Create note
  static Future<bool> createNote(Note note) async {
    try {
      await _box.put(note.id, note);
      return true;
    } catch (e) {
      print('Error creating note: $e');
      return false;
    }
  }

  // Get note by ID
  static Note? getNoteById(String id) {
    return _box.get(id);
  }

  // Get all notes for a user (excluding soft deleted)
  static List<Note> getNotesForUser(String userId) {
    return _box.values
        .where((note) => note.userId == userId && !note.isDeleted)
        .toList()
      ..sort((a, b) => b.lastEdited.compareTo(a.lastEdited)); // Latest first
  }

  // Get notes by category
  static List<Note> getNotesByCategory(String userId, String category) {
    return _box.values
        .where((note) =>
            note.userId == userId &&
            note.category == category &&
            !note.isDeleted)
        .toList()
      ..sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
  }

  // Search notes
  static List<Note> searchNotes(String userId, String query) {
    final searchQuery = query.toLowerCase();
    return _box.values
        .where((note) =>
            note.userId == userId &&
            !note.isDeleted &&
            (note.title.toLowerCase().contains(searchQuery) ||
                note.content.toLowerCase().contains(searchQuery)))
        .toList()
      ..sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
  }

  // Update note
  static Future<bool> updateNote(Note note) async {
    try {
      note.lastEdited = DateTime.now();
      await _box.put(note.id, note);
      return true;
    } catch (e) {
      print('Error updating note: $e');
      return false;
    }
  }

  // Soft delete note
  static Future<bool> softDeleteNote(String id) async {
    try {
      final note = _box.get(id);
      if (note != null) {
        note.softDelete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error soft deleting note: $e');
      return false;
    }
  }

  // Permanently delete note
  static Future<bool> deleteNote(String id) async {
    try {
      await _box.delete(id);
      return true;
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }

  // Get deleted notes (for trash feature)
  static List<Note> getDeletedNotes(String userId) {
    return _box.values
        .where((note) => note.userId == userId && note.isDeleted)
        .toList()
      ..sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
  }

  // Restore note from trash
  static Future<bool> restoreNote(String id) async {
    try {
      final note = _box.get(id);
      if (note != null) {
        note.restore();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring note: $e');
      }
      return false;
    }
  }

  // Get statistics
  static Map<String, int> getUserNoteStats(String userId) {
    final allNotes = _box.values.where((note) => note.userId == userId);
    final activeNotes = allNotes.where((note) => !note.isDeleted);
    final deletedNotes = allNotes.where((note) => note.isDeleted);

    return {
      'total': allNotes.length,
      'active': activeNotes.length,
      'deleted': deletedNotes.length,
    };
  }
}
