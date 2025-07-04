import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/colors.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
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

  void _editField(String fieldName, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$fieldName Düzenle'),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: fieldName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({fieldName.toLowerCase(): controller.text});
                Navigator.pop(context);
                _loadData(); // Güncelleme sonrası yenile
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String? value, IconData icon, bool editable) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
        subtitle: Text(value ?? ''),
        trailing: editable
            ? IconButton(icon: const Icon(Icons.edit, color: AppColors.primaryColor),
            onPressed: () => _editField(title, value ?? ''))
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (data == null) return const Center(child: Text('Bilgiler yüklenemedi.'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilgilerim'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoTile('Ad', data!['ad'], Icons.person, true),
          _buildInfoTile('Soyad', data!['soyad'], Icons.person, true),
          _buildInfoTile('Telefon', data!['telefon'], Icons.phone, true),
          _buildInfoTile('Firma', data!['firma'], Icons.business, true),
          _buildInfoTile('VKN', data!['vkn'], Icons.confirmation_num, true),
          _buildInfoTile('Adres', data!['adres'], Icons.location_on, true),
          _buildInfoTile('Email', data!['email'], Icons.email, true),
          _buildInfoTile('Rol', data!['rol'], Icons.security, false),
        ],
      ),
    );
  }
}
