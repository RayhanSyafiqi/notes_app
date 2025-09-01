import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static User? _currentUser;

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data['meta']['status'] == 'success') {
        // Save token
        final token = data['data']['token'];
        await ApiClient.saveToken(token);

        // Load user profile
        _currentUser = User.fromJson(data['data']['user']);

        return {'success': true, 'message': data['meta']['message']};
      } else {
        return {'success': false, 'message': data['meta']['message']};
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        return {
          'success': false,
          'message': errorData['meta']['message'] ?? 'Registration failed'
        };
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data['meta']['status'] == 'success') {
        // Save token
        final token = data['data']['token'];
        await ApiClient.saveToken(token);

        // Load user profile
        _currentUser = User.fromJson(data['data']['user']);

        return {'success': true, 'message': data['meta']['message']};
      } else {
        return {'success': false, 'message': data['meta']['message']};
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        return {
          'success': false,
          'message': errorData['meta']['message'] ?? 'Login failed'
        };
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiClient.dio.get('/user');

      final data = response.data;
      if (data['meta']['status'] == 'success') {
        _currentUser = User.fromJson(data['data']);
        return {'success': true, 'user': _currentUser};
      } else {
        return {'success': false, 'message': data['meta']['message']};
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expired
        await logout();
        return {'success': false, 'message': 'Session expired'};
      }

      if (e.response != null) {
        final errorData = e.response!.data;
        return {
          'success': false,
          'message': errorData['meta']['message'] ?? 'Failed to get profile'
        };
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  static Future<void> logout() async {
    try {
      // Call logout API if available
      await ApiClient.dio.post('/logout');
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      // Always clear local data
      _currentUser = null;
      await ApiClient.removeToken();
    }
  }

  static User? getCurrentUser() {
    return _currentUser;
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.getToken();
    return token != null && _currentUser != null;
  }

  static Future<void> loadCurrentUser() async {
    final token = await ApiClient.getToken();
    if (token != null) {
      final result = await getProfile();
      if (!result['success']) {
        print('Failed to load user profile: ${result['message']}');
      }
    }
  }
}
