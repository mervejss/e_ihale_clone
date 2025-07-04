import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _logoButtonController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoButtonAnimation;

  @override
  void initState() {
    super.initState();

    // Arka plan animasyonu
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );

    // Logo ve buton animasyonu
    _logoButtonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _logoButtonAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoButtonController,
        curve: Curves.easeInOut,
      ),
    );

    _logoButtonController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              width: width - 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    Colors.blue.shade700,
                    Colors.lightBlue.shade300,
                    Colors.cyan.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [_backgroundAnimation.value * 0.3, 0.5, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 3,
                  color: Colors.blueAccent.withOpacity(_backgroundAnimation.value),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _logoButtonAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.secondaryColor,

                            width: 4,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo_teklifingelsin.jpg',
                          height: 300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: _logoButtonAnimation,
                      child: _buildButton(context, "Kayıt Ol", const RegisterScreen()),
                    ),
                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: _logoButtonAnimation,
                      child: _buildButton(context, "Giriş Yap", const LoginScreen()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget screen) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}