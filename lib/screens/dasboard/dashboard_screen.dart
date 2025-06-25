import 'package:e_ihale_clone/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1; // Varsayılan: İhaleler sayfası

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  final List<Widget> _pages = [
    const Center(child: Text('Anasayfa')),
    const Center(child: Text('İhaleler')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1e529b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teklifin Gelsin',style: TextStyle(color: Color(0xFF1e529b)),),
        actions: [
          /*IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: _signOut,
          ),*/
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1e529b),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/images/logo_teklifingelsin.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Teklifin Gelsin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // 🟦 ÜST GRUP
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: primaryColor),
              title: const Text('Finansal Durum'),
              onTap: () => Navigator.pushNamed(context, '/finance'),
            ),
            ListTile(
              leading: const Icon(Icons.gavel, color: primaryColor),
              title: const Text('İhalelerim'),
              onTap: () => Navigator.pushNamed(context, '/my-auctions'),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return, color: primaryColor),
              title: const Text('İade Taleplerim'),
              onTap: () => Navigator.pushNamed(context, '/returns'),
            ),

            const Divider(thickness: 0.8, color: Colors.grey),

            // 🟨 ORTA GRUP
            ListTile(
              leading: const Icon(Icons.question_answer, color: primaryColor),
              title: const Text('Sıkça Sorulan Sorular'),
              onTap: () => Navigator.pushNamed(context, '/faq'),
            ),
            ListTile(
              leading: const Icon(Icons.article, color: primaryColor),
              title: const Text('Genel Şartlar'),
              onTap: () => Navigator.pushNamed(context, '/terms'),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: primaryColor),
              title: const Text('Hakkımızda'),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),

            const Divider(thickness: 0.8, color: Colors.grey),

            // 🔴 ALT GRUP
            ListTile(
              leading: const Icon(Icons.logout, color: primaryColor),
              title: const Text('Çıkış Yap'),
              onTap: () => _signOut(),
            ),

          ],
        ),
      ),


      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1e529b), // Aktif ikon & yazı rengi
        unselectedItemColor: Colors.grey,           // Pasif ikon & yazı rengi
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel),
            label: 'İhaleler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),

    );
  }
}
