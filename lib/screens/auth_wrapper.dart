import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Yükleniyorsa
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Kullanıcı giriş yaptıysa
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // Kullanıcı oturum açmamışsa
        return const HomeScreen();
      },
    );
  }
}
