import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_pages/profile_info_page.dart';
import 'profile_pages/change_password_page.dart';
import 'profile_pages/email_verification_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1e529b);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Kullanıcı bilgileri alınamadı.'));
        }

        final data = snapshot.data!;
        final String ad = data['ad']?.trim() ?? '';
        final String soyad = data['soyad']?.trim() ?? '';
        final String email = data['email']?.trim() ?? '';

        // Baş harfleri oluştur
        final List<String> adParcalari = ad.split(' ').where((e) => e.isNotEmpty).toList();
        String initials = adParcalari.map((e) => e[0]).join();
        if (soyad.isNotEmpty) {
          initials += soyad[0];
        }
        initials = initials.toUpperCase();

        // Ad ve soyadı düzgün formatla yaz
        String formattedAd = adParcalari.map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase()).join(' ');
        String formattedSoyad = soyad.toUpperCase();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),

            // ✅ Avatar
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: primaryColor,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ İsim Soyisim
            Center(
              child: Text(
                '$formattedAd $formattedSoyad',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ✅ Email
            Center(
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // 🔹 Menü
            ListTile(
              leading: const Icon(Icons.person_outline, color: primaryColor),
              title: const Text('Bilgilerim'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileInfoPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: primaryColor),
              title: const Text('Şifremi Değiştir'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined, color: primaryColor),
              title: const Text('E-Posta Onayı'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmailVerificationPage()),
              ),
            ),
          ],
        );
      },
    );
  }
}
