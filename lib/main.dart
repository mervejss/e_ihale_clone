import 'package:e_ihale_clone/screens/auth_wrapper.dart';
import 'package:e_ihale_clone/screens/dashboard_screen.dart';
import 'package:e_ihale_clone/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // AuthWrapper başlangıç ekranı olarak atanıyor
      initialRoute: '/auth_wrapper',
      routes: {
        '/auth_wrapper': (context) => AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
