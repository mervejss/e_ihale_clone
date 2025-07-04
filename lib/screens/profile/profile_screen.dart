import 'package:e_ihale_clone/screens/forgot_password_screen.dart';
import 'package:e_ihale_clone/screens/profile/profile_pages/change_password_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import 'profile_pages/profile_info_page.dart';
import 'profile_pages/email_verification_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      data = doc.exists ? doc.data() : null;
    }
    setState(() => loading = false);
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    // Geri dönüldüğünde yenile
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (data == null) return const Center(child: Text('Kullanıcı bilgileri alınamadı.'));

    final ad = (data!['ad'] ?? '').toString().trim();
    final soyad = (data!['soyad'] ?? '').toString().trim();
    final email = (data!['email'] ?? '').toString().trim();

    final adParcalari = ad.split(' ').where((e) => e.isNotEmpty).toList();
    String initials = adParcalari.map((e) => e[0]).join();
    if (soyad.isNotEmpty) initials += soyad[0];
    initials = initials.toUpperCase();

    final formattedAd = adParcalari.map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase()).join(' ');
    final formattedSoyad = soyad.toUpperCase();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryColor,
              child: Text(initials, style: const TextStyle(color: AppColors.secondaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text('$formattedAd $formattedSoyad', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor))),
          const SizedBox(height: 4),
          Center(child: Text(email, style: const TextStyle(fontSize: 14, color: Colors.black54))),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.primaryColor),
            title: const Text('Bilgilerim'),
            onTap: () => _openPage(const ProfileInfoPage()),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppColors.primaryColor),
            title: const Text('Şifremi Değiştir'),
            onTap: () => _openPage(const ChangePasswordPage()),
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined, color: AppColors.primaryColor),
            title: const Text('E-Posta Onayı'),
            onTap: () => _openPage(const EmailVerificationPage()),
          ),
        ],
      ),
    );
  }
}
