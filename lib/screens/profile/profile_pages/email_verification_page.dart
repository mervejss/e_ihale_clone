
// screens/profile/email_verification_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  void _checkVerificationStatus() async {
    await user?.reload();
    setState(() {
      _isVerified = user?.emailVerified ?? false;
    });
  }

  void _sendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama e-postası gönderildi.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Posta Onayı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('E-posta adresiniz: ${user?.email ?? 'Bilinmiyor'}'),
            const SizedBox(height: 16),
            Text('Doğrulama durumu: ${_isVerified ? 'Onaylandı' : 'Onaylanmadı'}'),
            const SizedBox(height: 20),
            if (!_isVerified)
              ElevatedButton(
                onPressed: _sendVerificationEmail,
                child: const Text('Tekrar Onay E-postası Gönder'),
              ),
          ],
        ),
      ),
    );
  }
}