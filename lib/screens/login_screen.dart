import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import 'dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/text_field_widget.dart';
import 'discover_brands_screen.dart';
import 'forgot_password_screen.dart';
import 'package:e_ihale_clone/widgets/save_result_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _isPasswordVisible = false;

  void _loginUser() async {
    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        _showDialog(true, "Giriş başarılı!");
      }
    } catch (e) {
      _showDialog(false, "Giriş sırasında hata: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showDialog(bool isSuccess, String message) {
    showDialog(
      context: context,
      builder: (context) => SaveResultDialog(
        isSuccess: isSuccess,
        message: message,
      ),
    ).then((_) {
      if (isSuccess) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DiscoverBrandsScreen()),
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Yap"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _emailController,
              label: "Email",
              hintText: "E-posta adresinizi girin",
              icon: Icons.email,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: "Şifre",
              hintText: "Şifrenizi girin",
              icon: Icons.lock,
              obscureText: !_isPasswordVisible,
              isRequired: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                );
              },
              child: const Text("Şifremi Unuttum?"),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              child: const Text("Giriş Yap"),
            ),
          ],
        ),
      ),
    );
  }
}