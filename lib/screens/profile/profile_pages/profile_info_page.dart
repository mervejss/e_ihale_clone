import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileInfoPage extends StatelessWidget {
  const ProfileInfoPage({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  void _editField(BuildContext context, String fieldName, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$fieldName Düzenle'),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: fieldName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({fieldName.toLowerCase(): controller.text});
              }
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1e529b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilgilerim'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
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
              _buildInfoTile(context, 'Ad', data['ad'], Icons.person, true),
              _buildInfoTile(context, 'Soyad', data['soyad'], Icons.person, true),
              _buildInfoTile(context, 'Telefon', data['telefon'], Icons.phone, true),
              _buildInfoTile(context, 'Firma', data['firma'], Icons.business, true),
              _buildInfoTile(context, 'VKN', data['vkn'], Icons.confirmation_num, true),
              _buildInfoTile(context, 'Adres', data['adres'], Icons.location_on, true),
              _buildInfoTile(context, 'Email', data['email'], Icons.email, true),
              _buildInfoTile(context, 'Rol', data['rol'], Icons.security, false), // düzenlenemez
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String? value, IconData icon, bool editable) {
    const Color primaryColor = Color(0xFF1e529b);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        subtitle: Text(value ?? ''),
        trailing: editable
            ? IconButton(
          icon: const Icon(Icons.edit, color: primaryColor),
          onPressed: () => _editField(context, title, value ?? ''),
        )
            : null,
      ),
    );
  }
}
