import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import 'dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/text_field_widget.dart';
import 'home_screen.dart';
import 'package:e_ihale_clone/widgets/save_result_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _firmaController = TextEditingController();
  final TextEditingController _vknController = TextEditingController();
  final TextEditingController _adresController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _sifreTekrarController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _registerUser() async {
    final ad = _adController.text.trim();
    final soyad = _soyadController.text.trim();
    final telefon = _telefonController.text.trim();
    final firma = _firmaController.text.trim();
    final vkn = _vknController.text.trim();
    final adres = _adresController.text.trim();
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();
    final sifreTekrar = _sifreTekrarController.text.trim();

    if (ad.isEmpty || soyad.isEmpty || telefon.isEmpty ||
        firma.isEmpty || vkn.isEmpty || adres.isEmpty ||
        email.isEmpty || sifre.isEmpty || sifreTekrar.isEmpty) {
      _showDialog(false, "Lütfen tüm alanları doldurun.");
      return;
    }

    if (sifre != sifreTekrar) {
      _showDialog(false, "Şifreler eşleşmiyor.");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await _authService.registerWithEmailAndPasswordExtended(
        email: email,
        password: sifre,
        ad: ad,
        soyad: soyad,
        telefon: telefon,
        firma: firma,
        vkn: vkn,
        adres: adres,
      );

      if (user != null) {
        _showDialog(true, "Kayıt başarılı!");
      }
    } catch (e) {
      _showDialog(false, "Kayıt sırasında hata: ${e.toString()}");
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
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _adController,
                label: "Ad",
                hintText: "Adınızı girin",
                isRequired: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _soyadController,
                label: "Soyad",
                hintText: "Soyadınızı girin",
                isRequired: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _telefonController,
                label: "Telefon No",
                hintText: "Telefon numaranızı girin",
                isRequired: true,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _firmaController,
                label: "Firma İsmi",
                hintText: "Firma ismini girin",
                isRequired: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _vknController,
                label: "VKN / Vergi Kimlik No",
                hintText: "VKN girin",
                isRequired: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _adresController,
                label: "Adres",
                hintText: "Adresinizi girin",
                isRequired: true,
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _emailController,
                label: "Email",
                hintText: "E-posta adresinizi girin",
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _sifreController,
                label: "Şifre",
                hintText: "Şifrenizi girin",
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
              const SizedBox(height: 10),
              CustomTextField(
                controller: _sifreTekrarController,
                label: "Şifre Tekrar",
                hintText: "Şifrenizi tekrar girin",
                obscureText: !_isConfirmPasswordVisible,
                isRequired: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                ),
                child: const Text("Kayıt Ol"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}