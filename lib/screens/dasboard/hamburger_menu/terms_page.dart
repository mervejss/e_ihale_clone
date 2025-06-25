import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Genel Şartlar')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Buraya Genel Şartlar gelecek...'),
      ),
    );
  }
}
