import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hakkımızda')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Buraya hakkımızda gelecek...'),
      ),
    );
  }
}
