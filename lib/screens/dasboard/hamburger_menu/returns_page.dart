import 'package:flutter/material.dart';

class ReturnsPage extends StatelessWidget {
  const ReturnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İade Taleplerim')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Buraya İade Taleplerim gelecek...'),
      ),
    );
  }
}
