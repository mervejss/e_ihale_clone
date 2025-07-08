import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../utils/colors.dart';
import '../../../../services/firestore_service.dart';
import 'auctions_pages/widgets/simple_auction_card.dart'; // Import the SimpleAuctionCard widget

class AuctionsPage extends StatefulWidget {
  const AuctionsPage({super.key});

  @override
  State<AuctionsPage> createState() => _AuctionsPageState();
}

class _AuctionsPageState extends State<AuctionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> tabs = ['Telefon', 'Bilgisayar', 'Aksesuar', 'Anakart', 'Teknik parça'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      _scrollToSelected();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    double offset = 0.0;
    for (int i = 0; i < _tabController.index; i++) {
      offset += _getTabWidth(i);
    }
    double selectedWidth = _getTabWidth(_tabController.index);
    final screenWidth = MediaQuery.of(context).size.width;
    _scrollController.animateTo(
      offset - (screenWidth / 2) + (selectedWidth / 2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  double _getTabWidth(int index) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: tabs[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size.width + 28;
  }

  Widget _buildTabBar() {
    return Container(
      height: 55,
      color: AppColors.primaryColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final bool isSelected = _tabController.index == index;
            return GestureDetector(
              onTap: () => _tabController.animateTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                      : [],
                  border: Border.all(
                    color: isSelected ? AppColors.secondaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryColor : AppColors.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 18 : 14,
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: _buildTabBar(),
        ),
        body: TabBarView(
          controller: _tabController,
          children: tabs.map((category) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _firestoreService.getAuctionsByCategory(category),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Bir hata oluştu.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Bu kategoride henüz herhangi bir ihale bulunmuyor.'));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final auction = snapshot.data![index];
                      return SimpleAuctionCard(auction: auction);
                    },
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}