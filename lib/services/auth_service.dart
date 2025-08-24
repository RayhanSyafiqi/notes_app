import '../models/user.dart';
import '../repositories/user_repository.dart';
import 'hive_service.dart';

class AuthService {
  static User? _currentUser;

  static Future<bool> register(
      String email, String password, String name) async {
    final user = User.create(
      email: email,
      password: password, // Consider hashing in production
      name: name,
    );

    return await UserRepository.createUser(user);
  }

  static Future<bool> login(String email, String password) async {
    final user = UserRepository.validateLogin(email, password);
    if (user != null) {
      _currentUser = user;
      await _saveCurrentUserToSettings();
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    _currentUser = null;
    await HiveService.settingsBox.delete('current_user_id');
  }

  static User? getCurrentUser() {
    return _currentUser;
  }

  static Future<void> _saveCurrentUserToSettings() async {
    if (_currentUser != null) {
      await HiveService.settingsBox.put('current_user_id', _currentUser!.id);
    }
  }

  static Future<void> loadCurrentUser() async {
    final userId = HiveService.settingsBox.get('current_user_id');
    if (userId != null) {
      _currentUser = UserRepository.getUserById(userId);
    }
  }

  static Future<bool> updateUserProfile({
    String? email,
    String? name,
    String? password,
  }) async {
    if (_currentUser != null) {
      _currentUser!.updateInfo(
        email: email,
        name: name,
        password: password,
      );
      return await UserRepository.updateUser(_currentUser!);
    }
    return false;
  }
}
