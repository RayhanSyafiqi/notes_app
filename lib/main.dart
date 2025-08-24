import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'services/auth_service.dart';
import 'page/loginpage.dart';
import 'page/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.init();

  // Load current user if exists
  await AuthService.loadCurrentUser();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthService.getCurrentUser() != null
          ? HomePage(username: AuthService.getCurrentUser()?.name ?? '')
          : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
