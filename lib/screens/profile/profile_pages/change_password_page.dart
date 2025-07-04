import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_ihale_clone/utils/colors.dart';
import 'package:e_ihale_clone/widgets/save_confirmation_dialog.dart';
import 'package:e_ihale_clone/widgets/save_result_dialog.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/text_field_widget.dart';

import '../../home_screen.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      if (!mounted) return;
      _showInvalidDialog('Bütün alanlar doldurulmalıdır.');
      return;
    }

    if (newPassword.length < 6) {
      if (!mounted) return;
      _showInvalidDialog('Yeni şifre en az 6 karakter uzunluğunda olmalıdır.');
      return;
    }

    if (newPassword != confirmPassword) {
      if (!mounted) return;
      _showInvalidDialog('Yeni şifreler eşleşmiyor.');
      return;
    }

    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      if (!mounted) return;
      _showInvalidDialog('Kullanıcı bulunamadı.');
      return;
    }

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    try {
      await user.reauthenticateWithCredential(cred);
      if (!mounted) return;

      // Show confirmation dialog before updating the password
      await _showConfirmationDialog(
        onSave: () async {
          try {
            await user.updatePassword(newPassword);
            if (!mounted) return;

            // Show success dialog and log out the user
            _showSuccessDialog('Şifreniz başarıyla güncellendi. Lütfen tekrar giriş yapın.');
            Future.delayed(Duration(milliseconds: 3500), () async {
              await _auth.signOut(); // Log out the user
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Adjust to your HomeScreen
                );
              }
            });
          } catch (e) {
            if (!mounted) return;
            _showErrorDialog('Şifre güncellenemedi: ${e.toString()}');
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Eski şifrenizi yanlış girdiniz.';
          break;
        case 'user-not-found':
          errorMessage = 'Kullanıcı bulunamadı.';
          break;
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi.';
          break;
        case 'invalid-credential':
          errorMessage = 'Girdiğiniz kimlik bilgileri geçersiz, yanlış veya süresi dolmuş.';
          break;
        default:
          errorMessage = 'Hata: ${e.toString()}'; // Use toString for more detail
      }
      if (!mounted) return;
      _showErrorDialog(errorMessage);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Hata oluştu: ${e.toString()}');
    }
  }

  Future<void> _showInvalidDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => SaveResultDialog(
        isSuccess: false,
        message: message,
      ),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => SaveResultDialog(
        isSuccess: false,
        message: message,
      ),
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => SaveResultDialog(
        isSuccess: true,
        message: message,
      ),
    );
  }

  Future<void> _showConfirmationDialog({required VoidCallback onSave}) async {
    await showDialog(
      context: context,
      builder: (_) => SaveConfirmationDialog(onSave: onSave),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifre Değiştir"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Şifrenizi değiştirmek için gerekli bilgileri girin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _oldPasswordController,
              label: "Eski Şifre",
              icon: Icons.lock,
              isPasswordVisible: _isOldPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isOldPasswordVisible = !_isOldPasswordVisible;
                });
              },
            ),
            _buildPasswordField(
              controller: _newPasswordController,
              label: "Yeni Şifre",
              icon: Icons.lock_open,
              isPasswordVisible: _isNewPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
            ),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: "Yeni Şifre (Tekrar)",
              icon: Icons.lock_outline,
              isPasswordVisible: _isConfirmPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              child: const Text("Şifreyi Değiştir"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      icon: icon,
      isRequired: true,
      hintText: "$label girin",
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: AppColors.primaryColor,
        ),
        onPressed: onVisibilityToggle,
      ),
      obscureText: !isPasswordVisible,
    );
  }
}