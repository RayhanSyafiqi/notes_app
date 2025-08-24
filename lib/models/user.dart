import 'package:hive/hive.dart';

part 'user.g.dart'; // Generated file

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String password; // Consider hashing in production

  @HiveField(3)
  late String name;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  User.create({
    required this.email,
    required this.password,
    required this.name,
  }) {
    id = DateTime.now().millisecondsSinceEpoch.toString();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  void updateInfo({String? email, String? name, String? password}) {
    if (email != null) this.email = email;
    if (name != null) this.name = name;
    if (password != null) this.password = password;
    updatedAt = DateTime.now();
    save(); // Hive method to save changes
  }
}
