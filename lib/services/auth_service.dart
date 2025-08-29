import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static User? _currentUser;

  static Future<bool> register(
      String email, String password, String name) async {
    final response = await ApiService.register(
      name: name,
      email: email,
      password: password,
    );

    if (response['success']) {
      // Auto login after successful registration
      return await login(email, password);
    }

    return false;
  }

  static Future<bool> login(String email, String password) async {
    final response = await ApiService.login(
      email: email,
      password: password,
    );

    if (response['success']) {
      final data = response['data'];
      final token = data['token'];

      // Save token
      await ApiService.saveToken(token);

      // Load user profile
      await loadCurrentUser();

      return true;
    }

    return false;
  }

  static Future<void> logout() async {
    _currentUser = null;
    await ApiService.removeToken();
  }

  static User? getCurrentUser() {
    return _currentUser;
  }

  static Future<void> loadCurrentUser() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getProfile();

        if (response['success']) {
          final userData = response['data']['user'];
          _currentUser = User.fromJson(userData);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading current user: $e');
      }
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }

  static String getErrorMessage(Map<String, dynamic> response) {
    return response['message'] ?? 'An error occurred';
  }
}
