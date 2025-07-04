import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_ihale_clone/utils/colors.dart';
import 'package:e_ihale_clone/widgets/save_result_dialog.dart';

import 'home_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _resetPassword() async {
    final email = _emailController.text.trim();
    print("Kullanıcının girdiği email: $email");

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const SaveResultDialog(
          isSuccess: false,
          message: 'Lütfen e-posta adresinizi girin.',
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      // ✅ Dialog sonrası yönlendirme
      await showDialog(
        context: context,
        builder: (_) => const SaveResultDialog(
          isSuccess: true,
          message: 'Şifre yenileme bağlantısı e-posta adresinize gönderildi.',
        ),
      );

      // 🔁 Ana sayfaya yönlendir
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = "Bir hata oluştu.";
      if (e.code == 'user-not-found') {
        message = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta adresi.';
      }

      showDialog(
        context: context,
        builder: (_) => SaveResultDialog(
          isSuccess: false,
          message: message,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifremi Unuttum"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Şifre yenileme bağlantısı göndermek için e-posta adresinizi girin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "E-posta",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              child: const Text("Şifre Yenileme Bağlantısı Gönder"),
            ),
          ],
        ),
      ),
    );
  }
}
