import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/colors.dart';
import 'widgets/auction_card.dart';
import 'my_auctions_page_detail.dart';

class MyAuctionsPage extends StatefulWidget {
  const MyAuctionsPage({super.key});

  @override
  State<MyAuctionsPage> createState() => _MyAuctionsPageState();
}

class _MyAuctionsPageState extends State<MyAuctionsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;
  Future<List<Map<String, dynamic>>>? _myAuctions;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _myAuctions = _firestoreService.getUserAuctions(_currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benim İhalelerim'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: _currentUser == null
          ? const Center(child: Text('Giriş yapmamışsınız.'))
          : FutureBuilder<List<Map<String, dynamic>>>(
        future: _myAuctions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Henüz bir ihale oluşturmadınız.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final auction = snapshot.data![index];
                return AuctionCard(auction: auction);
              },
            );
          }
        },
      ),
    );
  }
}