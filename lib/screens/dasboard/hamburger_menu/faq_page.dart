import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sıkça Sorulan Sorular')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Buraya sıkça sorulan sorular gelecek...'),
      ),
    );
  }
}
