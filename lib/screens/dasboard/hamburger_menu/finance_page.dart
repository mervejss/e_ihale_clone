import 'package:flutter/material.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finans Durum')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Buraya Finans Durum gelecek...'),
      ),
    );
  }
}
