import 'package:dio/dio.dart';
import '../models/note.dart';
import 'api_client.dart';

class NoteService {
  static Future<List<Note>> getAllNotes() async {
    try {
      final response = await ApiClient.dio.get('/notes');

      final data = response.data;
      if (data['meta']['status'] == 'success') {
        final notesData = data['data'] as List<dynamic>;
        return notesData.map((json) => Note.fromJson(json)).toList();
      } else {
        throw Exception(data['meta']['message']);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['meta']['message'] ?? 'Failed to load notes');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/notes',
        data: {
          'title': title,
          'content': content,
        },
      );

      final data = response.data;
      if (data['meta']['status'] == 'success') {
        return Note.fromJson(data['data']);
      } else {
        throw Exception(data['meta']['message']);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(
            errorData['meta']['message'] ?? 'Failed to create note');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<Note> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      final response = await ApiClient.dio.put(
        '/notes/$id',
        data: {
          'title': title,
          'content': content,
        },
      );

      final data = response.data;
      if (data['meta']['status'] == 'success') {
        return Note.fromJson(data['data']);
      } else {
        throw Exception(data['meta']['message']);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(
            errorData['meta']['message'] ?? 'Failed to update note');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<bool> deleteNote(String id) async {
    try {
      final response = await ApiClient.dio.delete('/notes/$id');

      final data = response.data;
      return data['meta']['status'] == 'success';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(
            errorData['meta']['message'] ?? 'Failed to delete note');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<Note?> getNoteById(String id) async {
    try {
      final response = await ApiClient.dio.get('/notes/$id');

      final data = response.data;
      if (data['meta']['status'] == 'success') {
        return Note.fromJson(data['data']);
      } else {
        return null;
      }
    } on DioException catch (e) {
      print('Get note by ID error: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }
}
