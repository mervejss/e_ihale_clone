import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

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

    if (ad.isEmpty ||
        soyad.isEmpty ||
        telefon.isEmpty ||
        firma.isEmpty ||
        vkn.isEmpty ||
        adres.isEmpty ||
        email.isEmpty ||
        sifre.isEmpty ||
        sifreTekrar.isEmpty) {
      _showMessage("Lütfen tüm alanları doldurun.");
      return;
    }

    if (sifre != sifreTekrar) {
      _showMessage("Şifreler eşleşmiyor.");
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

        _showInfoDialog(ad, soyad, telefon, firma, vkn, adres, email);
        // Firestore kaydını yaptıysan veya dialogu kapattıysan direkt anasayfaya dön
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      _showMessage("Kayıt sırasında hata: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showInfoDialog(String ad, String soyad, String telefon, String firma,
      String vkn, String adres, String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kayıt Bilgileri"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text("Ad: $ad"),
                Text("Soyad: $soyad"),
                Text("Telefon: $telefon"),
                Text("Firma: $firma"),
                Text("VKN: $vkn"),
                Text("Adres: $adres"),
                Text("Email: $email"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog kapansın
                Navigator.pop(context); // İstersen kayıt sonrası login sayfasına dönebilir
              },
              child: const Text("Kapat"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _telefonController.dispose();
    _firmaController.dispose();
    _vknController.dispose();
    _adresController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(_adController, "Ad"),
              const SizedBox(height: 10),
              _buildTextField(_soyadController, "Soyad"),
              const SizedBox(height: 10),
              _buildTextField(_telefonController, "Telefon No", keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildTextField(_firmaController, "Firma İsmi"),
              const SizedBox(height: 10),
              _buildTextField(_vknController, "VKN / Vergi Kimlik No"),
              const SizedBox(height: 10),
              _buildTextField(_adresController, "Adres", maxLines: 4),
              const SizedBox(height: 10),
              _buildTextField(_emailController, "Email", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildTextField(_sifreController, "Şifre", obscureText: true),
              const SizedBox(height: 10),
              _buildTextField(_sifreTekrarController, "Şifre Tekrar", obscureText: true),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _registerUser,
                child: const Text("Kayıt Ol"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool obscureText = false,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
