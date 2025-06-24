import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Firebase'den kullanıcı çıkış işlemi
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Çıkış sonrası giriş ekranına yönlendirme

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Hoşgeldin, ${user?.email ?? 'Kullanıcı'}!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
