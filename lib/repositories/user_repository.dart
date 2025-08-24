import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../services/hive_service.dart';

class UserRepository {
  static Box<User> get _box => HiveService.userBox;

  // Create user
  static Future<bool> createUser(User user) async {
    try {
      // Check if email already exists
      if (getUserByEmail(user.email) != null) {
        return false; // Email already exists
      }

      await _box.put(user.id, user);
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Get user by email
  static User? getUserByEmail(String email) {
    try {
      return _box.values.firstWhere(
        (user) => user.email == email,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  static User? getUserById(String id) {
    return _box.get(id);
  }

  // Update user
  static Future<bool> updateUser(User user) async {
    try {
      await _box.put(user.id, user);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  static Future<bool> deleteUser(String id) async {
    try {
      await _box.delete(id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user: $e');
      }
      return false;
    }
  }

  // Get all users
  static List<User> getAllUsers() {
    return _box.values.toList();
  }

  // Login validation
  static User? validateLogin(String email, String password) {
    try {
      return _box.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null; // User not found or password incorrect
    }
  }
}
