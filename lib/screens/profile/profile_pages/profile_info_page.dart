
// screens/profile/profile_info_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileInfoPage extends StatelessWidget {
  const ProfileInfoPage({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilgilerim')),
      body: FutureBuilder<Map<String, dynamic>?> (
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Bilgiler yüklenemedi.'));
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('Ad'), subtitle: Text(data['ad'] ?? '')),
              ListTile(title: const Text('Soyad'), subtitle: Text(data['soyad'] ?? '')),
              ListTile(title: const Text('Telefon'), subtitle: Text(data['telefon'] ?? '')),
              ListTile(title: const Text('Firma'), subtitle: Text(data['firma'] ?? '')),
              ListTile(title: const Text('VKN'), subtitle: Text(data['vkn'] ?? '')),
              ListTile(title: const Text('Adres'), subtitle: Text(data['adres'] ?? '')),
              ListTile(title: const Text('Email'), subtitle: Text(data['email'] ?? '')),
              ListTile(title: const Text('Rol'), subtitle: Text(data['rol'] ?? '')),

            ],
          );
        },
      ),
    );
  }
}
