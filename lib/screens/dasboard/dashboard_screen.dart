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
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-İhale'),
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
          padding: EdgeInsets.all(10),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF001F54), // Koyu lacivert
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 125,
                    width: 125,
                    padding: const EdgeInsets.all(3),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      'assets/images/logo_eihale.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),



                ],
              ),
            ),


            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('Sıkça Sorulan Sorular'),
              onTap: () => Navigator.pushNamed(context, '/faq'),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Genel Şartlar'),
              onTap: () => Navigator.pushNamed(context, '/terms'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Hakkımızda'),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
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
