// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'profile_pages/profile_info_page.dart';
import 'profile_pages/change_password_page.dart';
import 'profile_pages/email_verification_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Bilgilerim'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileInfoPage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Şifremi Değiştir'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.verified_user_outlined),
          title: const Text('E-Posta Onayı'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmailVerificationPage()),
          ),
        ),
      ],
    );
  }
}

