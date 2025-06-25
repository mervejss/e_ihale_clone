import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dasboard/dashboard_screen.dart';
import 'home_screen.dart';
import '../services/user_role_service.dart';

class AuthWrapper extends StatelessWidget {
  final UserRoleService _roleService = UserRoleService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: _roleService.getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (roleSnapshot.hasData) {
                final rol = roleSnapshot.data!;
                // Şu an tüm roller için aynı sayfa, sonra farklılaştırabilirsin
                return const DashboardScreen();
              }

              return const Scaffold(
                body: Center(child: Text('Rol bilgisi alınamadı')),
              );
            },
          );
        }

        return const HomeScreen();
      },
    );
  }
}
