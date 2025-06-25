import 'package:flutter/material.dart';

class MyAuctionsPage extends StatelessWidget {
  const MyAuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İhalelerim')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Buraya İhalelerim gelecek...'),
      ),
    );
  }
}
